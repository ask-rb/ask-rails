# frozen_string_literal: true

require "rails/generators"

module Ask
  module Generators
    class WorkflowGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("workflow/templates", __dir__)

      desc "Creates a workflow under app/workflows — module directory, Workflow class, and steps directory"

      def verify_ask_graph
        return if defined?(Ask::Graph)

        raise ::Thor::Error, <<~MSG.strip
          ask-graph is not installed. Add it to your Gemfile and run `bundle install` first:

            gem "ask-graph"
        MSG
      end

      def create_workflow_directory
        empty_directory "app/workflows/#{file_name}"
      end

      def create_workflow
        template "workflow.rb", "app/workflows/#{file_name}/workflow.rb"
      end

      def create_steps_directory
        empty_directory "app/workflows/#{file_name}/steps"
      end
    end
  end
end
