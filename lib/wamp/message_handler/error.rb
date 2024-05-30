# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call handler with error message
    class Error < Base
      def handle
        validate_received_message

        stored_data[:callback].call(response)
      end

      def response
        Type::Error.new(uri: message.error, details: message.details)
      end
    end
  end
end
