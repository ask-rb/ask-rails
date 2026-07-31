# frozen_string_literal: true

require "rails/generators"

module Ask
  module Generators
    class AgentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("agent/templates", __dir__)

      desc "Creates an agent under app/agents/<name>/ — the ask-agent directory convention with agent.rb, instructions.md, and tools/"

      def create_agent
        template "agent.rb", "app/agents/#{file_name}/agent.rb"
        template "instructions.md", "app/agents/#{file_name}/instructions.md"
        empty_directory "app/agents/#{file_name}/tools"
      end
    end
  end
end
