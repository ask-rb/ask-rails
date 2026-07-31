# frozen_string_literal: true

require_relative "actions/result"
require_relative "actions/context"
require_relative "actions/backend"

module Ask
  # Actions — a convention for user-facing operations callable from any channel.
  #
  # Every action lives in app/actions/, responds to .call(context:, params:),
  # and returns an Ask::Actions::Result. Dispatch them by name so any channel —
  # web, Slack, voice — can invoke the same operation:
  #
  #   Ask::Actions.dispatch(action: "chats.create", context: context, params: {})
  #
  # By convention, "chats.create" resolves to Chats::Create (app/actions/chats/create.rb).
  # Register explicitly to override the convention or to list actions in
  # Ask::Actions.available:
  #
  #   Ask::Actions.register "chats.create", Chats::Create
  module Actions
    class << self
      def register(action, klass)
        Backend.register(action, klass)
      end

      def dispatch(action:, context:, params: {})
        Backend.dispatch(action: action, context: context, params: params)
      end

      def resolve(action)
        Backend.resolve(action)
      end

      def available
        Backend.available
      end

      def reset!
        Backend.reset!
      end
    end
  end
end
