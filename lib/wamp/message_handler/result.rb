# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Result
    class Result < Base
      def handle
        validate_received_message
        if message.details[:progress]
          store[store_key].fetch(:handler).call(response)
        else
          stored_data.fetch(:handler).call(response)
        end
      end

      def response
        Type::Result.new(args: message.args, kwargs: message.kwargs, details: message.details)
      end
    end
  end
end
