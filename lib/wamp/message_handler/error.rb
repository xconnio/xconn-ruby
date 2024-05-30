# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call handler with error message
    class Error < Base
      def handle
        validate_received_message

        stored_data[:callback].call(message)
      end
    end
  end
end
