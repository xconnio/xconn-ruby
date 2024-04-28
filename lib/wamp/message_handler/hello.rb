# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Hello
    class Hello
      def initialize
        @message = message
        @connection = connection
      end

      def send_message; end
    end
  end
end
