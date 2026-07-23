# frozen_string_literal: true

require "rails"
require "ask/agent"
require "ask/auth"

module Ask
  module Rails
    class << self
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def agent_session(**extra)
        # Auto-prune if configured
        cleanup! if configuration.max_session_age || configuration.max_sessions

        tools = configuration.tools.map { |t| t.is_a?(Class) ? t.new : t }
        prompt = extra.delete(:system_prompt) || configuration.system_prompt || default_system_prompt

        # Resolve environment-specific permissions and wire into agent hooks
        hooks = build_environment_hooks

        Ask::Agent::Session.new(
          model: configuration.default_model,
          max_turns: configuration.max_turns,
          system_prompt: prompt,
          tools: tools,
          persistence: configuration.persistence_adapter,
          hooks: hooks,
          **extra
        )
      end

      def discover_tools!
        self.configuration.tools = Ask::Tools::Shell::TOOLS.map(&:new) + core_rails_tools + discovered_user_tools
      end

      # Prune old sessions and audit logs based on configuration limits.
      #
      # Removes sessions older than +max_session_age+ seconds, and limits the
      # total number of sessions to +max_sessions+ (deleting the oldest first).
      # Audit log entries older than the oldest kept session are also removed.
      #
      # Call manually via rake task or cron, or configure limits to auto-prune
      # on agent_session creation.
      def cleanup!
        prune_old_sessions
        limit_session_count
      end

      def root
        @root ||= Pathname.new(File.expand_path("..", __dir__))
      end

      private

      def build_environment_hooks
        env_mode = configuration.effective_mode
        return {} unless env_mode

        perms = Ask::Agent::Extensions::Permissions.new(mode: env_mode)
        { before_tool: [perms.method(:before_tool_call)] }
      rescue ArgumentError => e
        warn "[ask-rails] Invalid environment mode: #{e.message}"
        {}
      end

      def prune_old_sessions
        age = configuration.max_session_age
        return unless age&.> 0
        return unless persistence_available?

        cutoff = age.seconds.ago
        count = 0

        configuration.persistence_adapter.list.each do |id|
          data = configuration.persistence_adapter.load(id)
          created = data&.dig(:metadata, :created_at)
          if created && Time.parse(created) < cutoff
            configuration.persistence_adapter.delete(id)
            count += 1
          end
        end

        count
      rescue StandardError
        nil
      end

      def limit_session_count
        max = configuration.max_sessions
        return unless max&.> 0
        return unless persistence_available?

        sessions = configuration.persistence_adapter.list
        excess = sessions.size - max
        return unless excess > 0

        # Delete oldest sessions first
        with_timestamps = sessions.map { |id|
          data = configuration.persistence_adapter.load(id)
          created = data&.dig(:metadata, :created_at)
          [id, created ? Time.parse(created) : Time.at(0)]
        }.sort_by(&:last)

        with_timestamps.first(excess).each do |id, _|
          configuration.persistence_adapter.delete(id)
        end

        excess
      rescue StandardError
        nil
      end

      def persistence_available?
        defined?(ActiveRecord::Base) &&
          ActiveRecord::Base.connection.data_source_exists?("ask_sessions")
      rescue StandardError
        false
      end

      def core_rails_tools
        CORE_RAILS_TOOLS.map(&:new)
      end

      def discovered_user_tools
        tools = []
        files = Dir[::Rails.root.join("app", "tools", "*.rb")]
        files.each do |f|
          require f
          klass = File.basename(f, ".rb").camelize.constantize rescue next
          tools << klass if klass < Ask::Rails::Tool
        end
        tools
      rescue
        tools
      end

      def default_system_prompt
        <<~PROMPT
          You are a Ruby on Rails software engineer.
          You have direct access to the application's code, database, and runtime.
          Use your tools to inspect and modify the codebase.
          Once you have enough information, stop calling tools and give your answer.
        PROMPT
      end
    end
  end
end

require_relative "rails/version"
require_relative "rails/engine"
require_relative "rails/configuration"
require_relative "rails/audit_log"
require_relative "rails/environment_permissions"
require_relative "rails/auth"
require_relative "rails/persistence"
require_relative "rails/service_discovery"
require_relative "rails/tool"
require_relative "rails/tools/read_file"
require_relative "rails/tools/run_command"
require_relative "rails/tools/search_codebase"
require_relative "rails/tools/read_routes"
require_relative "rails/tools/query_database"
require_relative "rails/tools/read_model"
require_relative "rails/tools/read_log"
require_relative "rails/tools/schema_graph"
require_relative "rails/tools/route_inspector"

# Railtie is loaded only when Rails is fully available
if defined?(::Rails::Railtie)
  require_relative "rails/railtie"
end

# Define after all tool files are loaded so the constants resolve
Ask::Rails::CORE_RAILS_TOOLS = [
  Ask::Rails::Tools::ReadFile, Ask::Rails::Tools::RunCommand,
  Ask::Rails::Tools::SearchCodebase, Ask::Rails::Tools::ReadRoutes,
  Ask::Rails::Tools::QueryDatabase, Ask::Rails::Tools::ReadModel,
  Ask::Rails::Tools::ReadLog, Ask::Rails::Tools::SchemaGraph,
  Ask::Rails::Tools::RouteInspector
].freeze
