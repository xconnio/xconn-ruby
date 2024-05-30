# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call
    class Call < Base
      def send_message(handler)
        store[store_key] = { handler: handler, callback: handler }

        send_serialized message
      end
    end
  end
end
