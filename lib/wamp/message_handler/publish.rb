# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Publish message
    class Publish < Base
      def send_message(&callback)
        send_serialized message

        return unless message.options[:acknowledge]

        store[store_key] = { callback: callback }
      end
    end
  end
end
