# frozen_string_literal: true

module Wamp
  module MessageHandler
    # send unregister message
    class Goodbye < Base
      def send_message(&callback)
        store[store_key] = { callback: callback }

        send_serialized message
      end

      def handle
        goodbye = Wampproto::Message::Goodbye.new({}, "wamp.close.goodbye_and_out")
        send_serialized goodbye
      end
    end
  end
end
