# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call
    class Call < Base
      # Call and Result share the same request_id
      # Invocation and Yield share the same request_id
      def handle
        invocation = find_connection.handle_call(message)
        connection.invocation_requests[invocation.request_id] = message.request_id
        connection.transmit invocation
      end

      def send_message(handler)
        send_serialized message

        store[store_key] = { handler: handler }
      end
    end
  end
end
