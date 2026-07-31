# frozen_string_literal: true

module Ask
  module Actions
    # A per-request bag of context. Channel adapters construct it with
    # whatever the app needs — user, session, workspace, channel, voice call —
    # and actions read from it. Attributes become accessors on the instance.
    #
    # @example
    #   context = Ask::Actions::Context.new(user: user, session: session, workspace: workspace)
    #   context.user      # => user
    #   context.workspace # => workspace
    class Context
      def initialize(**attributes)
        attributes.each { |name, value| define_attribute(name, value) }
      end

      private

      def define_attribute(name, value)
        singleton_class.attr_accessor(name)
        public_send("#{name}=", value)
      end
    end
  end
end
