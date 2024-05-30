# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Published confirmation message
    class Published < Base
      def handle
        validate_received_message

        deliver_response
      end
    end
  end
end
