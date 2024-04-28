# frozen_string_literal: true

module Wamp
  module MessageHandler
    # send unregister message
    class Unregister < Base
      def send_message(&callback)
        store[store_key] = { callback: callback, registration_id: message.registration_id }

        send_serialized message
      end
    end
  end
end
