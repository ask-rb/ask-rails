# frozen_string_literal: true

require "json"

module Ask
  module Rails
    class ChatController < ::ActionController::Base
      layout "ask/rails/application"

      before_action :authenticate!, unless: -> { Ask::Rails::Auth.check.nil? }
      before_action :set_session, only: [:message, :stream, :history, :show]

      # GET /ask — main chat interface
      def index
        @sessions = load_sessions
        @active_session = @sessions.first
        render :index
      end

      # POST /ask/sessions — create a new session
      def create
        session_id = SecureRandom.uuid

        agent = build_agent_session
        agent.run("Hello") # warm up
        agent.save

        # Store minimal session metadata
        store_session_metadata(session_id, agent)

        redirect_to ask_rails.root_path
      end

      # GET /ask/sessions/:id — show a specific session
      def show
        @messages = load_session_messages(@session_id)
        render json: { id: @session_id, messages: @messages }
      end

      # GET /ask/sessions — list all sessions
      def index_sessions
        @sessions = load_sessions
        render json: @sessions
      end

      # POST /ask/sessions/:session_id/messages — send a message, get SSE stream
      def message
        prompt = params[:message].to_s.strip
        return head :bad_request if prompt.empty?

        response.headers["Content-Type"] = "text/event-stream"
        response.headers["Cache-Control"] = "no-cache"
        response.headers["X-Accel-Buffering"] = "no"

        # Disable buffering for streaming
        response.headers["Last-Modified"] = Time.now.httpdate

        self.response_body = Enumerator.new do |yielder|
          agent = resume_or_create_session(@session_id)

          yielder << "data: #{JSON.generate(type: 'start', session_id: @session_id)}\n\n"

          agent.run(prompt) do |chunk|
            if chunk.content&.length&.> 0
              yielder << "data: #{JSON.generate(type: 'delta', content: chunk.content)}\n\n"
            end
            if chunk.thinking&.length&.> 0
              yielder << "data: #{JSON.generate(type: 'thinking', content: chunk.thinking)}\n\n"
            end
          end

          agent.save
          @session = agent

          yielder << "data: #{JSON.generate(type: 'done', session_id: @session_id)}\n\n"
        end
      end

      # GET /ask/sessions/:session_id/stream — SSE stream for an existing session
      def stream
        response.headers["Content-Type"] = "text/event-stream"
        response.headers["Cache-Control"] = "no-cache"
        response.headers["X-Accel-Buffering"] = "no"

        self.response_body = Enumerator.new do |yielder|
          messages = load_session_messages(@session_id)
          yielder << "data: #{JSON.generate(type: 'history', messages: messages)}\n\n"

          # Keep connection open briefly for potential updates
          sleep 30
          yielder << "data: #{JSON.generate(type: 'keepalive')}\n\n"
        end
      end

      # GET /ask/sessions/:session_id/messages — get message history as JSON
      def history
        messages = load_session_messages(@session_id)
        render json: messages
      end

      # DELETE /ask/sessions — destroy all sessions
      def destroy
        persistence = Ask::Rails.configuration.persistence_adapter
        if persistence
          persistence.list.each { |id| persistence.delete(id) }
        end
        redirect_to ask_rails.root_path
      end

      private

      def authenticate!
        instance_eval(&Ask::Rails::Auth.check) if Ask::Rails::Auth.check
      end

      def set_session
        @session_id = params[:session_id] || params[:id]
        head :not_found unless @session_id
      end

      def build_agent_session(**extra)
        Ask::Rails.agent_session(**extra)
      end

      def resume_or_create_session(session_id)
        persistence = Ask::Rails.configuration.persistence_adapter

        if persistence
          data = persistence.load(session_id)
          if data
            session = Ask::Agent::Session.load(session_id, adapter: persistence)
            return session if session
          end
        end

        Ask::Rails.agent_session(persistence: persistence).tap do |s|
          s.instance_variable_set(:@id, session_id)
        end
      end

      def load_sessions
        persistence = Ask::Rails.configuration.persistence_adapter
        return [] unless persistence

        persistence.list.map do |id|
          data = persistence.load(id) || {}
          { id: id, created_at: data.dig(:metadata, :created_at), message_count: (data[:messages] || []).length }
        end.sort_by { |s| s[:created_at] || "" }.reverse
      end

      def load_session_messages(session_id)
        persistence = Ask::Rails.configuration.persistence_adapter
        return [] unless persistence

        data = persistence.load(session_id)
        return [] unless data

        (data[:messages] || []).map { |m|
          { role: m[:role], content: m[:content].to_s.truncate(200) }
        }
      end

      def store_session_metadata(session_id, agent)
        persistence = Ask::Rails.configuration.persistence_adapter
        return unless persistence

        persistence.save(session_id, {
          id: session_id,
          messages: agent.messages.map { |m|
            { role: m.role, content: m.content.to_s }
          },
          metadata: {
            model: ask_rails_model,
            created_at: Time.now.iso8601,
            updated_at: Time.now.iso8601
          }
        })
      end

      def ask_rails_model
        Ask::Rails.configuration.default_model
      end
    end
  end
end
