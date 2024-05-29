# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Receive unsubscribed
    class Unsubscribed < Base
      def handle
        validate_received_message
        delete_topic store.delete(alt_store_key)

        deliver_response(response)
      end

      def response
        Type::Success.new
      end

      private

      def alt_store_key
        "subscription_#{subscription_id}"
      end

      def delete_topic(data)
        store.delete data.fetch(:topic)
      end

      def subscription_id
        stored_data.fetch(:subscription_id)
      end
    end
  end
end
