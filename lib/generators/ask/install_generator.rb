# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Ask
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::ActiveRecord::Generators::Migration

      source_root File.expand_path("install/templates", __dir__)

      desc "Sets up ask-rb for Rails — creates initializer, agents and workflows directories, and shared state migrations"

      class_option :skip_graph, type: :boolean, default: false,
                                desc: "Skip workflow scaffolding even if ask-graph is installed"

      def create_initializer
        template "initializer.rb", "config/initializers/ask.rb"
      end

      def create_agents_directory
        empty_directory "app/agents"
      end

      def create_application_agent
        template "application_agent.rb", "app/agents/application_agent.rb"
      end

      def create_actions_directory
        empty_directory "app/actions"
      end

      def create_application_action
        template "application_action.rb", "app/actions/application_action.rb"
      end

      def create_workflows_directory
        return if skip_graph?
        empty_directory "app/workflows"
      end

      def create_application_workflow
        return if skip_graph?
        template "application_workflow.rb", "app/workflows/application_workflow.rb"
      end

      def create_state_migration
        migration_template "state_migration.rb", "db/migrate/create_ask_state.rb"
      end

      def create_audit_log_migration
        migration_template "audit_log_migration.rb", "db/migrate/create_ask_audit_logs.rb"
      end

      private

      def skip_graph?
        options[:skip_graph] || !defined?(Ask::Graph)
      end

        def migration_version
          ActiveRecord::Migration.current_version
        end
    end
  end
end
