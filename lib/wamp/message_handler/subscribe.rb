# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Request subscription
    class Subscribe < Base
      def send_message(handler, &callback)
        store[store_key] = { handler: handler, callback: callback, topic: message.topic }

        send_serialized message
      end
    end
  end
end
