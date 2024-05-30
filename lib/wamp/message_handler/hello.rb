# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Hello
    class Hello < Base
      def handle
        msg, is_welcome = connection.acceptor.receive(connection.serializer.serialize(message))
        connection.transmit msg
        connection.router.attach_client(connection) if is_welcome
      end

      def send_message
        connection.transmit connection.joiner.send_hello
      end
    end
  end
end
