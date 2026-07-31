# frozen_string_literal: true

module Ask
  module Actions
    # The uniform response shape every action returns. Channel adapters
    # (web controllers, Slack handlers, voice agents) consume the same
    # contract regardless of which surface a request came from.
    #
    # @example
    #   Ask::Actions::Result.ok(message: "Booking confirmed", data: { booking: booking })
    #   Ask::Actions::Result.error(message: "Slot unavailable", code: :slot_taken)
    class Result
      attr_reader :ok, :message, :data, :code

      def initialize(ok:, message:, data: {}, code: nil)
        @ok = ok
        @message = message
        @data = data
        @code = code
      end

      def ok?
        ok
      end

      def error?
        !ok
      end

      def to_h
        { ok: ok, message: message, data: data, code: code }
      end

      def self.ok(message: "", data: {}, code: nil)
        new(ok: true, message: message, data: data, code: code)
      end

      def self.error(message: "", data: {}, code: nil)
        new(ok: false, message: message, data: data, code: code)
      end
    end
  end
end
