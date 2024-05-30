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

      def invocation_response
        Type::Invocation.new(args: message.args, kwargs: message.kwargs, details: message.details)
      end

      private

      def send_yield_message(handler)
        result = handler.call(invocation_response)
        yield_message = if result.instance_of?(Type::Result)
          Wampproto::Message::Yield.new(message.request_id, result.details, *result.args, **result.kwargs)
        else
          Wampproto::Message::Yield.new(message.request_id, {}, result)
        end
        send_serialized yield_message
      end
    end
  end
end
