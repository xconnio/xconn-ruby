# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Result
    class Result < Base
      def handle
        validate_received_message
        stored_data.fetch(:handler).call(response)
      end

      def response
        Type::Result.new(args: message.args, kwargs: message.kwargs, details: message.details)
      end
    end
  end
end
