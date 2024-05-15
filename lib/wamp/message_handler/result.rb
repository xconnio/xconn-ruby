# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Result
    class Result < Base
      def handle
        validate_received_message
        stored_data.fetch(:handler).call(message)
      end
    end
  end
end
