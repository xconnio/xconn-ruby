# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Publish message
    class Publish < Base
      def send_message(&callback)
        store[store_key] = { callback: callback } if message.options[:acknowledge]

        send_serialized message
      end
    end
  end
end
