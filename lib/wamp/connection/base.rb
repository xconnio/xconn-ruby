# frozen_string_literal: true

require_relative "websocket_client"
require_relative "../message/validate"

module Wamp
  module Connection
    # class to start accepting connnections
    class Base
      class UnsupportedSerializer < StandardError; end

      include WebSocket::Driver::EventEmitter
      attr_reader :websocket, :url

      def initialize(url = "ws://localhost:8080/ws", realm = "realm1", options = {})
        super()
        @url = url
        @realm = realm
        @options = Message::Validate.options!(options, [:serializer])

        @websocket = Wamp::Connection::WebsocketClient.new(self, protocols)
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

      def serializer
        @options.fetch(:serializer, :json).to_sym
      end

      def protocols
        protocol = { json: "wamp.2.json", cbor: "wamp.2.cbor", msgpack: "wamp.2.msgpack" }[serializer]
        raise UnsupportedSerializer unless protocol

        [protocol]
      end

      def encode(wamp_message)
        coder.encode wamp_message
      end

      def decode(websocket_message)
        coder.decode websocket_message
      end

      def coder
        @coder ||= case serializer
                   when :json then Wamp::Serializer::JSON
                   when :msgpack then Wamp::Serializer::MessagePack
                   when :cbor then Wamp::Serializer::Cbor
                   else
                     raise "Unsupported protocol #{websocket.protocol}"
                   end
      end
    end
  end
end
