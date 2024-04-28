# frozen_string_literal: true

module Wamp
  module MessageHandler
    # publish event to subscriber
    class Register < Base
      def send_message(handler, &callback)
        store[store_key] = { handler: handler, callback: callback, procedure: message.procedure }

        send_serialized message
      end
    end
  end
end
