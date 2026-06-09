# frozen_string_literal: true

module Ask
  module Rails
    class Persistence
      def initialize(model_class: nil)
        @model_class = model_class || default_model_class
      end

      def save(session_id, data)
        record = @model_class.find_or_initialize_by(session_id: session_id)
        record.update!(data: data)
      end

      def load(session_id)
        record = @model_class.find_by(session_id: session_id)
        record&.data
      end

      def delete(session_id)
        @model_class.where(session_id: session_id).delete_all
      end

      def list
        @model_class.pluck(:session_id)
      end

      private

      def default_model_class
        # Lazy reference so the model class doesn't need to exist at load time
        ask_session_model = Class.new(::ActiveRecord::Base) do
          self.table_name = "ask_sessions"
        end
        # Store it as a constant so it's reusable
        unless Object.const_defined?(:AskSession)
          Object.const_set(:AskSession, ask_session_model)
        end
        AskSession
      end
    end
  end
end
