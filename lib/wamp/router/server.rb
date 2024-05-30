# frozen_string_literal: true

require "nio4r"
require "socket"
require_relative "connection"

module Wamp
  # Router
  module Router
    # Connection Handler
    class Server
      attr_reader :selector, :options

      def initialize(router, options = {})
        @options = options
        @selector = NIO::Selector.new
        @router = router
        # @router.add_realm(options.fetch(:realm, "realm1"))
      end

      def run
        trap("INT") { throw :ctrl_c }

        create_tcp_server
        options_message
        catch :ctrl_c do
          loop do
            accept_connection
          end
        end
      end

      def options_message
        host = options.fetch(:host, "127.0.0.1")
        port = options.fetch(:port, 8080)
        realm = options.fetch(:realm, "realm1")
        puts "Starting router on ws://#{host}:#{port}/ws and added Realm: #{realm}"
      end

      def create_tcp_server
        server = TCPServer.new(options.fetch(:host, "127.0.0.1"), options.fetch(:port, 8080))
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
        connection = Connection.new(client) do |conn|
          selector.deregister(monitor)
          @router.detach_client(conn)
        end
        connection.router = @router
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
