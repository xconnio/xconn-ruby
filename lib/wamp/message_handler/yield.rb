# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Yield
    class Yield
      def initialize
        @message = message
        @connection = connection
      end

      def handle
        call_request_id = connection.invocation_requests.delete(message.request_id)
        handler = call_requests.delete(call_request_id)
        handler.call(message)
      end

      def send_message(handler)
        connection.transmit message
        connection.call_requests[message.request_id] = handler
      end
    end
  end
end
