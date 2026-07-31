# frozen_string_literal: true

require "rails/generators"

module Ask
  module Generators
    # Creates an action under app/actions. Actions are operations callable
    # from any channel by name — dispatch them with Ask::Actions.dispatch.
    #
    #   rails generate ask:action create_workspace
    #   # => app/actions/create_workspace.rb  (dispatch name: "create_workspace")
    #
    #   rails generate ask:action chats create
    #   # => app/actions/chats/create.rb      (dispatch name: "chats.create")
    class ActionGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("action/templates", __dir__)

      desc "Creates an action under app/actions — a user-facing operation callable from any channel"

      def create_action
        template "action.rb", action_path
      end

      private

      def action_path
        if namespaced?
          "app/actions/#{namespace_name}/#{action_name}.rb"
        else
          "app/actions/#{action_name}.rb"
        end
      end

      def namespaced?
        args.any?
      end

      def namespace_name
        file_name
      end

      def action_name
        namespaced? ? args.first.underscore : file_name
      end

      def namespace_class_name
        namespace_name.camelize
      end

      def action_class_name
        action_name.camelize
      end

      def dispatch_name
        namespaced? ? "#{namespace_name}.#{action_name}" : action_name
      end
    end
  end
end
