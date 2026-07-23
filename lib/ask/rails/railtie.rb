# frozen_string_literal: true

module Ask
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        desc "Prune old sessions and audit logs based on configuration limits"
        task ask_rails: :cleanup do
          count = Ask::Rails.cleanup!
          puts "Cleaned up #{count || 0} sessions."
        end
      end

      generators do
        require_relative "../../generators/ask/rails/install/install_generator"
      end

      initializer "ask_rails.configure" do |app|
        Ask::Rails.configuration.default_model ||= ENV["ASK_DEFAULT_MODEL"] || "gpt-4o"
        Ask::Rails.configuration.max_turns ||= (ENV["ASK_MAX_TURNS"] || 25).to_i
      end

      initializer "ask_rails.discover_tools", after: :eager_load_most do
        Ask::Rails.discover_tools!
      end

      initializer "ask_rails.discover_services", after: :eager_load_most do
        Ask::Rails::ServiceDiscovery.discover!
      end
    end
  end
end
