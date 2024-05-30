# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call
    class Invocation < Base
      def handle
        connection.session.receive_message(message)
        data = store.fetch(alt_store_key)

        send_yield_message data.fetch(:handler)
      end

      def alt_store_key
        "registration_#{message.registration_id}"
      end

      private

      def send_yield_message(handler)
        result = handler.call(message)
        yield_message = result if result.instance_of?(Wampproto::Message::Yield)
        yield_message ||= Wampproto::Message::Yield.new(message.request_id, {}, result)
        send_serialized yield_message
      end
    end
  end
end
