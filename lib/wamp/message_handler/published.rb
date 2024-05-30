# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Published confirmation message
    class Published < Base
      def handle
        validate_received_message

        deliver_response(response)
      end

      def response
        Type::Publication.new(publication_id: message.publication_id)
      end
    end
  end
end
