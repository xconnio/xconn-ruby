# frozen_string_literal: true

module Wamp
  module Connection
    # Client Session
    class Session
      attr_reader :joiner, :session, :store, :api
      attr_accessor :executor, :stream

      def initialize(joiner = Wampproto::Joiner.new("realm1"))
        @joiner = joiner
        @session = Wampproto::Session.new(joiner.serializer)
        @api = MessageHandler::Api.new(self)
        @store = {}
      end

      def on_join(&block)
        self.executor = block
      end

      def on_open
        stream.on_message joiner.send_hello
      end

      def on_message(data)
        handler = MessageHandler.resolve(data, self)
        handler.handle
      end

      def transmit(data)
        stream.on_message data
      end
    end
  end
end
