# frozen_string_literal: true

module Wamp
  module MessageHandler
    # publish event to subscriber
    class Event < Base
      def handle
        validate_received_message

        store[alt_store_key].fetch(:handler).call(message)
      end

      def alt_store_key
        "subscription_#{message.subscription_id}"
      end
    end
  end
end
