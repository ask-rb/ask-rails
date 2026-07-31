# frozen_string_literal: true

module Ask
  module Actions
    # Dispatches named actions to their classes.
    #
    # Resolution order:
    #   1. Explicitly registered actions (Ask::Actions.register)
    #   2. Convention: "chats.create" resolves to Chats::Create
    #
    # Convention resolution works with Zeitwerk — app/actions/chats/create.rb
    # is autoloaded as Chats::Create with no configuration.
    class Backend
      class UnknownAction < StandardError
        def initialize(action)
          super(<<~MSG.strip)
            Unknown action #{action.inspect}. Define it at app/actions/ \
            (e.g. app/actions/chats/create.rb for "chats.create") or register \
            it with Ask::Actions.register.
          MSG
        end
      end

      CONVENTION = /\A[a-z0-9_.]+\z/

      class << self
        def register(action, klass)
          registered[action.to_s] = klass
        end

        def registered
          @registered ||= {}
        end

        def reset!
          @registered = {}
        end

        def available
          registered.keys
        end

        def dispatch(action:, context:, params: {})
          resolve(action).call(context: context, params: params)
        end

        def resolve(action)
          name = action.to_s
          registered[name] || resolve_by_convention(name) || unknown_action!(name)
        end

        private

        def resolve_by_convention(name)
          return nil unless name.match?(CONVENTION)

          name.split(".").map { |part| part.split("_").map(&:capitalize).join }.join("::").safe_constantize
        end

        def unknown_action!(name)
          raise UnknownAction, name
        end
      end
    end
  end
end
