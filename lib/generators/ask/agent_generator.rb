# frozen_string_literal: true

require "rails/generators"

module Ask
  module Generators
    class AgentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("agent/templates", __dir__)

      desc "Creates an agent under app/agents — subclass ApplicationAgent with a model and system prompt"

      def create_agent
        template "agent.rb", "app/agents/#{file_name}.rb"
      end
    end
  end
end
