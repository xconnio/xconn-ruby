# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Receive subscribed
    class Subscribed < Base
      def handle
        validate_received_message

        store[alt_store_key] = { handler: stored_data.fetch(:handler), topic: stored_data.fetch(:topic) }
        store_topic

        deliver_response(response)
      end

      def response
        Type::Subscription.new(subscription_id: message.subscription_id)
      end

      def alt_store_key
        "subscription_#{message.subscription_id}"
      end

      def store_topic
        topic = stored_data.fetch(:topic)
        store[topic] = message.subscription_id
      end
    end
  end
end
