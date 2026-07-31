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
      attr_reader :ok, :message, :data, :code, :redirect_path

      def initialize(ok:, message:, data: {}, code: nil, redirect_path: nil)
        @ok = ok
        @message = message
        @data = data
        @code = code
        @redirect_path = redirect_path
      end

      def ok?
        ok
      end

      def error?
        !ok
      end

      def to_h
        { ok: ok, message: message, data: data, code: code, redirect_path: redirect_path }
      end

      def self.ok(message: "", data: {}, code: nil, redirect_path: nil)
        new(ok: true, message: message, data: data, code: code, redirect_path: redirect_path)
      end

      def self.error(message: "", data: {}, code: nil, redirect_path: nil)
        new(ok: false, message: message, data: data, code: code, redirect_path: redirect_path)
      end
    end
  end
end
