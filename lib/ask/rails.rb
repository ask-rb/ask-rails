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
        tools = configuration.tools.map { |t| t.is_a?(Class) ? t.new : t }
        prompt = extra.delete(:system_prompt) || configuration.system_prompt || default_system_prompt

        Ask::Agent::Session.new(
          model: configuration.default_model,
          max_turns: configuration.max_turns,
          system_prompt: prompt,
          tools: tools,
          persistence: configuration.persistence_adapter,
          **extra
        )
      end

      def discover_tools!
        self.configuration.tools = Ask::Tools::Shell::TOOLS.map(&:new) + discovered_rails_tools
      end

      def root
        @root ||= Pathname.new(File.expand_path("..", __dir__))
      end

      private

      def discovered_rails_tools
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
require_relative "rails/configuration"
require_relative "rails/railtie"
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