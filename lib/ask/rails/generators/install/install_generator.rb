# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Ask
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        include ::Rails::Generators::Migration

        source_root File.expand_path("templates", __dir__)

        desc "Sets up ask-rb for Rails — creates initializer, agents directory, state and audit log migrations"

        def create_initializer
          template "initializer.rb", "config/initializers/ask.rb"
        end

        def create_application_agent
          template "application_agent.rb", "app/agents/application_agent.rb"
        end

        def create_agents_directory
          empty_directory "app/agents"
          create_file "app/agents/.keep", "" unless options[:skip_keep]
        end

        def create_state_migration
          migration_template "state_migration.rb", "db/migrate/create_ask_state.rb"
        end

        def create_audit_log_migration
          migration_template "audit_log_migration.rb", "db/migrate/create_ask_audit_logs.rb"
        end

        private

        def migration_version
          "[#{ActiveRecord::Migration.current_version}]"
        end
      end
    end
  end
end
