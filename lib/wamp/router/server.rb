# frozen_string_literal: true

require "nio4r"
require "socket"
require_relative "connection"

module Wamp
  # Router
  module Router
    # Connection Handler
    class Server
      attr_reader :selector

      def initialize
        @selector = NIO::Selector.new
      end

      def run
        trap("INT") { throw :ctrl_c }

        create_tcp_server
        catch :ctrl_c do
          loop do
            accept_connection
          end
        end
      end

      def create_tcp_server
        server = TCPServer.new("127.0.0.1", 8080)
        selector.register(server, :r)
      end

      def accept_connection
        selector.select do |monitor|
          case monitor.io
          when TCPServer
            create_connection(monitor.io.accept_nonblock)
          when TCPSocket
            monitor.value.call
          end
        end
      end

      def create_connection(client)
        monitor = selector.register(client, :r)
        connection = Connection.new(client) do |session|
          selector.deregister(monitor)
          Registrations.clean_registrations(session)
        end
        monitor.value = proc do
          connection.listen
        end
      end
    end

    @session_ids = {}
    class << self
      def create_identifier
        id = rand(100_000..(2**53))
        if @session_ids.include?(id)
          create_identifier
        else
          @session_ids[id] = id
          id
        end
      end
    end
  end
end
# TOP Level Doc
