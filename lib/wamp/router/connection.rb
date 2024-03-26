# frozen_string_literal: true

require "websocket/driver"

module Wamp
  module Router
    # TOP Level Doc
    class Connection
      include WebSocket::Driver::EventEmitter
      CONNECTING = 0
      OPEN       = 1
      CLOSING    = 2
      CLOSED     = 3

      attr_reader :socket, :session

      def initialize(socket, &cleanup)
        super()
        @cleanup = cleanup
        @socket = socket
        @driver = WebSocket::Driver.server(self)
        @driver.on(:open) { on_open(_1) }
        @driver.on(:message) { on_message(_1.data) }
        @driver.on(:close) { |evt| begin_close(evt.reason, evt.code) }
        @driver.on(:connect) { on_connect }
        @session = Wamp::Manager::Session.new(self)
        @ready_state = OPEN
      end

      def begin_close(reason, code)
        return if @ready_state == CLOSED

        @ready_state = CLOSING
        @close_params = [reason, code]

        @cleanup&.call(session)
        finalize_close
      end

      def finalize_close
        return if @ready_state == CLOSED

        @ready_state = CLOSED
        socket.close
        @driver.close
      end

      def on_connect
        @driver.start if WebSocket::Driver.websocket?(@driver.env)
      end

      def listen(&block)
        return unless @ready_state == OPEN

        data = socket.read_nonblock(4096, exception: false)
        case data
        when :wait_readable
          # do nothing
        when nil
          block.call
          @driver.close
        else
          receive_data(data)
        end
      end

      # triggers on_message
      def receive_data(data)
        return unless @ready_state == OPEN

        @driver.parse(data)
      end

      # called when @driver.text is invoked
      def write(data)
        socket.write(data)
      end

      def transmit(message)
        @driver.text(encode(message))
      end

      private

      def on_open(_evt)
        return unless @ready_state == CONNECTING

        @ready_state = OPEN
      end

      def on_message(data)
        msg = Wamp::Message.resolve(coder.decode(data))
        manager = Wamp::Manager::Event.resolve(msg, session)
        manager.emit_event(msg)
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

      def coder
        @coder ||= Wamp::Serializer::JSON
      end
    end
  end
end
