# frozen_string_literal: true

require "websocket/driver"

# Testing
class Authenticator
  def self.authenticate(request)
    Wampproto::Acceptor::Response.new(request.authid, "role")
  end
end

module Wamp
  module Router
    # TOP Level Doc
    class Connection < Client
      include WebSocket::Driver::EventEmitter
      CONNECTING = 0
      OPEN       = 1
      CLOSING    = 2
      CLOSED     = 3

      attr_reader :socket, :session, :acceptor

      def initialize(socket, &cleanup)
        super()
        @cleanup = cleanup
        @socket = socket
        @driver = WebSocket::Driver.server(self)
        @driver.on(:open) { on_open(_1) }
        @driver.on(:message) { on_message(_1.data) }
        @driver.on(:close) { |evt| begin_close(evt.reason, evt.code) }
        @driver.on(:connect) { on_connect }
        @ready_state = CONNECTING
      end

      def on_connect
        @driver.start if WebSocket::Driver.websocket?(@driver.env)
        choose_serializer_from @driver.env["HTTP_SEC_WEBSOCKET_PROTOCOL"]
        @acceptor = Wampproto::Acceptor.new(serializer, Authenticator)
      end

      def connection
        self
      end

      def begin_close(reason, code)
        return if @ready_state == CLOSED

        @ready_state = CLOSING
        @close_params = [reason, code]

        @cleanup&.call(self)
        finalize_close
      end

      def finalize_close
        return if @ready_state == CLOSED

        @ready_state = CLOSED
        @driver.close
        socket.close
      end

      def listen(&block)
        return unless [CONNECTING, OPEN].include?(@ready_state)

        data = socket.read_nonblock(4096, exception: false)
        case data
        when :wait_readable
          # do nothing
        when nil
          block&.call
          @driver.close
        else
          receive_data(data)
        end
      end

      # triggers on_message
      def receive_data(data)
        return unless [OPEN, CONNECTING].include?(@ready_state)

        @driver.parse(data)
      end

      # called when @driver.text is invoked
      def write(data)
        socket.write(data)
      end

      def transmit(message)
        # return false if @ready_state > OPEN

        case message
        when Wampproto::Message::Base then transmit(serializer.serialize(message))
        when Numeric then @driver.text(message.to_s)
        when String  then @driver.text(message)
        when Array   then @driver.binary(message)
        else false
        end
      end

      private

      def on_open(_evt)
        return unless @ready_state == CONNECTING

        @ready_state = OPEN
      end

      def on_close(message)
        return if @ready_state == CLOSED

        @ready_state = CLOSED
        socket.close
        @driver.close(message.code, message.reason)
      end

      def close(_code, _reason)
        @driver.close
      end

      def encode(wamp_message)
        coder.encode wamp_message
      end

      def decode(websocket_message)
        coder.decode websocket_message
      end

      attr_reader :serializer

      def choose_serializer_from(protocols)
        @serializer = if protocols.include?("wamp.2.msgpack")
          Wampproto::Serializer::Msgpack
        elsif protocols.include?("wamp.2.cbor")
          Wampproto::Serializer::Cbor
        elsif protocols.include?("wamp.2.json")
          Wampproto::Serializer::JSON
        else
          close
        end
      end
    end
  end
end
