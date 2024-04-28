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
    class WebSocketConnection
      attr_reader :url, :joiner, :session, :call_requests, :store, :websocket, :api
      attr_accessor :executor

      def initialize(url = "ws://localhost:8080/ws", joiner = Wampproto::Joiner.new("realm1"))
        @url        = url
        @joiner     = joiner
        @websocket = Wamp::Connection::WebsocketClient.new(self, protocols)
        @session = Wampproto::Session.new(joiner.serializer)
        @api = MessageHandler::Api.new(self)
        @store = {}
      end

      def run
        websocket.run
      ensure
        p "Close"
        websocket.close
      end

      def on_join(&block)
        puts "blocking is saving"
        self.executor = block
      end

      def on_open
        data = joiner.send_hello
        transmit  data
      end

      def on_message(data)
        handler = MessageHandler.resolve(data, self)
        handler.handle
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
