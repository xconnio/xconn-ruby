# frozen_string_literal: true

require_relative "websocket_client"

module Wamp
  module Connection
    # class to start accepting connnections
    class Base
      include WebSocket::Driver::EventEmitter
      attr_reader :websocket, :url

      def initialize(transport:, realm: :realm1, options: {})
        super()
        @url = transport
        @realm = realm
        @options = options

        @websocket = Wamp::Connection::WebsocketClient.new(self, @options[:protocols])
      end

      def run
        websocket.run
      ensure
        p "Close"
        close
      end

      def transmit(wamp_message)
        websocket.transmit encode(wamp_message)
      end

      def on_open; end

      def on_message(data)
        coder.decode(data)
      end

      def on_close(reason, code)
        p [:on_close, reason, code]
      end

      def on_error(message); end

      def close(code = 3000, reason = "Reason")
        websocket.close(code, reason)
      end

      private

      def encode(wamp_message)
        coder.encode wamp_message
      end

      def decode(websocket_message)
        coder.decode websocket_message
      end

      def coder
        @coder ||= case websocket.protocol
                   when "wamp.2.json" then Wamp::Serializer::JSON
                   when "wamp.2.msgpack" then Wamp::Serializer::MessagePack
                   when "wamp.2.cbor" then Wamp::Serializer::Cbor
                   else
                     raise "Unsupported protocol #{websocket.protocol}"
                   end
      end
    end
  end
end
