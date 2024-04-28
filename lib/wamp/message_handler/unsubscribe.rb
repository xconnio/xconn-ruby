# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Request subscription
    class Unsubscribe < Base
      def send_message(&callback)
        store[store_key] = { callback: callback, subscription_id: message.subscription_id }

        send_serialized message
      end
    end
  end
end
