# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Welcome
    class Welcome < Base
      def handle
        connection.executor&.call(connection.api)
      end
    end
  end
end
