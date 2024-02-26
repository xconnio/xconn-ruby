# frozen_string_literal: true

require "websocket/driver"
require_relative "stream"

module Wamp
  module Connection
    # handles opening connection and providing callbacks when data is avaialble
    class WebsocketClient
      CONNECTING = 0
      OPEN       = 1
      CLOSING    = 2
      CLOSED     = 3

      attr_reader :url

      def initialize(event_target, protocols) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @event_target = event_target

        @driver = @driver_started = nil
        @close_params = ["", 1006]

        @url = event_target.url
        @ready_state = CONNECTING

        @driver = WebSocket::Driver.client(self, protocols: protocols)

        @driver.on(:open)     { |_e| open }
        @driver.on(:message)  { |e| receive_message(e.data) }
        @driver.on(:close)    { |e| begin_close(e.reason, e.code) }
        @driver.on(:error)    { |e| emit_error(e.message) }

        @stream = Wamp::Connection::Stream.new(self)
      end

      def run
        start_driver
        @stream.run
      end

      def start_driver
        return if @driver_started

        @driver_started = true
        @driver.start
      end

      def write(data)
        @stream.write(data)
      rescue StandardError => e
        emit_error(e.message)
      end

      def transmit(message)
        return false if @ready_state > OPEN

        case message
        when Numeric then @driver.text(message.to_s)
        when String  then @driver.text(message)
        when Array   then @driver.binary(message)
        else false
        end
      end

      def connection_gone
        finalize_close
      end

      def close(code = nil, reason = nil)
        code   ||= 1000
        reason ||= ""

        unless code == 1000 || (code >= 3000 && code <= 4999)
          raise ArgumentError, "Failed to execute 'close' on WebSocket: " \
                               "The code must be either 1000, or between 3000 and 4999. " \
                               "#{code} is neither."
        end

        @ready_state = CLOSING unless @ready_state == CLOSED
        @driver.close(reason, code)
      end

      def parse(data)
        @driver.parse(data)
      end

      def alive?
        @ready_state == OPEN
      end

      # This is populated after successful handeshake
      def protocol
        @driver.protocol
      end

      private

      def open
        return unless @ready_state == CONNECTING

        @ready_state = OPEN

        @event_target.on_open
      end

      def receive_message(data)
        return unless @ready_state == OPEN

        @event_target.on_message(data)
      end

      def emit_error(message)
        return if @ready_state >= CLOSING

        @event_target.on_error(message)
      end

      def begin_close(reason, code)
        return if @ready_state == CLOSED

        @ready_state = CLOSING
        @close_params = [reason, code]

        @stream.close
        finalize_close
      end

      def finalize_close
        return if @ready_state == CLOSED

        @ready_state = CLOSED

        @event_target.on_close(*@close_params)
      end
    end
  end
end
