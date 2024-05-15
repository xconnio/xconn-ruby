# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Yield
    class Yield < Base
      def send_message(handler)
        connection.transmit message
        connection.call_requests[message.request_id] = handler
      end
    end
  end
end
