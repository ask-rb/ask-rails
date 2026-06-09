# frozen_string_literal: true

module Ask
  module Rails
    class Persistence
      def initialize(model_class: nil)
        @model_class = model_class
      end

      def save(session_id, data)
        record = model_class.find_or_initialize_by(session_id: session_id)
        record.update!(data: data)
      end

      def load(session_id)
        record = model_class.find_by(session_id: session_id)
        record&.data
      end

      def delete(session_id)
        model_class.where(session_id: session_id).delete_all
      end

      def list
        model_class.pluck(:session_id)
      end

      private

      def model_class
        @model_class || (raise "No model class configured. Use Persistence.new(model_class: MyModel)")
      end
    end
  end
end
