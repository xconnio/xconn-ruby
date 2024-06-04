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
    class Connection < Client # rubocop:disable Metrics/ClassLength
      include WebSocket::Driver::EventEmitter
      CONNECTING = 0
      OPEN       = 1
      CLOSING    = 2
      CLOSED     = 3
      SUPPORTED_PROTOCOLS = ["wamp.2.msgpack", "wamp.2.cbor", "wamp.2.json"].freeze

      attr_reader :socket, :session, :acceptor

      def initialize(socket, &cleanup) # rubocop:disable Lint/MissingSuper
        # super() # on_connect() does what super() does
        @cleanup = cleanup
        @socket = socket
        @driver = WebSocket::Driver.server(self, protocols: SUPPORTED_PROTOCOLS)
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
        @driver.close(*@close_params)
        socket.close
      end

      def listen(&block) # rubocop:disable Metrics/MethodLength
        return unless [CONNECTING, OPEN].include?(@ready_state)

        begin
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
        rescue StandardError => e
          puts e.message
          puts e.backtrace
          begin
            block&.call
            @driver.close
          rescue StandardError
            # Errno::ECONNRESET
            puts "Failed to handle: Errno::ECONNRESET"
          end
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

      def close(code, reason)
        @driver.close(reason, code)
      end

      attr_reader :serializer

      def choose_serializer_from(protocols) # rubocop:disable Metrics/MethodLength
        common_protocols = protocols.to_s.split(",") & SUPPORTED_PROTOCOLS
        protocol = common_protocols[0].to_s

        @serializer = if protocol.include?("wamp.2.msgpack")
          Wampproto::Serializer::Msgpack
        elsif protocols.include?("wamp.2.cbor")
          Wampproto::Serializer::Cbor
        elsif protocols.include?("wamp.2.json")
          Wampproto::Serializer::JSON
        else
          reason = "on_connect: protocols not supported '#{protocols}'."
          code = 1006
          puts reason
          @close_params = [reason, code]
          finalize_close
        end
      end
    end
  end
end
