# frozen_string_literal: true

require "nio4r"

module Wamp
  module Connection
    # creates actual socket and provides a way to read and write to it
    class Stream
      def initialize(socket_object)
        @socket_object = socket_object
        uri = URI.parse(socket_object.url)

        @selector = NIO::Selector.new
        @socket = TCPSocket.new(uri.host, uri.port)
        monitor = @selector.register(@socket, :r)
        monitor.value = proc { read_nonblock(monitor.io) }
      end

      def write(data)
        written = @socket.write_nonblock(data, exception: false)

        case written
        when :wait_writable
          # procceed
        when data.bytesize
          data.bytesize
        else
          puts [:incomplete_write]
        end
      end

      def receive(data)
        @socket_object.parse(data)
      end

      def run
        loop do
          @selector.select { |monitor| monitor.value.call if monitor.readable? }
          break if @closed
        end
      end

      def read_nonblock(io)
        incoming = io.read_nonblock(4096, exception: false)

        case incoming
        when :wait_readable
          nil
        when nil
          close
        else
          receive incoming
        end
      end

      def shutdown
        @selector.deregister(@socket)
        @socket.close
      end

      def close
        shutdown
        @socket_object.connection_gone
        @closed = true
      end
    end
  end
end
