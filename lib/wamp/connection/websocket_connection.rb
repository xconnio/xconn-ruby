# frozen_string_literal: true

require "wampproto"

# extending the class
class Wampproto::Joiner # rubocop:disable Style/ClassAndModuleChildren
  def joined?
    state == STATE_JOINED
  end
end

module Wamp
  module Connection
    # Conn
    class WebSocketConnection < Session
      attr_reader :url, :websocket

      def initialize(url = "ws://localhost:8080/ws", joiner = Wampproto::Joiner.new("realm1"))
        super(joiner)
        @url        = url
        @store      = {}
        @websocket  = Wamp::Connection::WebsocketClient.new(self, protocols)
      end

      def run
        websocket.run
      ensure
        p "Close"
        websocket.close
      end

      def on_open
        transmit joiner.send_hello
      end

      def transmit(data)
        websocket.transmit data
      end

      def on_close(reason, code)
        p [:on_close, reason, code]
      end

      def on_error; end

      private

      def protocols
        case joiner.serializer.name
        when Wampproto::Serializer::JSON.name then "wamp.2.json"
        when Wampproto::Serializer::Msgpack.name then "wamp.2.msgpack"
        when Wampproto::Serializer::Cbor.name then "wamp.2.cbor"
        end.then do |protocol|
          [protocol]
        end
      end
    end
  end
end
