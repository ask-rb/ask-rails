# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Ask
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      source_root File.expand_path("install/templates", __dir__)

      desc "Sets up ask-rb for Rails — creates initializer, state and audit log migrations"

      def create_initializer
        template "initializer.rb", "config/initializers/ask.rb"
      end

      def create_state_migration
        template "state_migration.rb", "db/migrate/#{next_migration_number}_create_ask_state.rb"
      end

      def create_audit_log_migration
        template "audit_log_migration.rb", "db/migrate/#{next_migration_number}_create_ask_audit_logs.rb"
      end

      private

      def next_migration_number
        # Rails requires exactly YYYYMMDDHHMMSS format
        @migration_suffix ||= 0
        now = Time.now.utc.strftime("%Y%m%d%H%M")
        "#{now}#{format('%02d', @migration_suffix)}"
      ensure
        @migration_suffix = (@migration_suffix || 0) + 1
      end
    end
  end
end
