# frozen_string_literal: true

module Ask
  module Rails
    class Configuration
      attr_accessor :default_model, :max_turns, :system_prompt,
                    :tool_concurrency, :persistence_adapter, :tools

      def initialize
        @default_model = "gpt-4o"
        @max_turns = 25
        @system_prompt = nil
        @tool_concurrency = 5
        @persistence_adapter = nil
        @tools = []
      end
    end
  end
end
