# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Call handler with error message
    class Error < Base
      def handle
        stored_data[:handler].call(message)
      end
    end
  end
end
