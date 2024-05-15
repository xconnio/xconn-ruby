# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Challenge
    class Challenge < Hello
      def handle
        connection.transmit connection.joiner.receive(connection.joiner.serializer.serialize(message))
      end
    end
  end
end
