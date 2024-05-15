# frozen_string_literal: true

require "forwardable"

module Wamp
  module MessageHandler
    # handles session
    class Api
      extend Forwardable

      attr_reader :connection, :session_id, :id_gen

      def initialize(connection)
        @connection = connection
        @id_gen = Wampproto::IdGenerator.new
      end

      def subscribe(topic, handler, options = {}, &block)
        message = Wampproto::Message::Subscribe.new(next_request_id, options, topic)
        action = MessageHandler::Subscribe.new(message, connection)
        action.send_message(handler, &block)
      end

      def unsubscribe(subscription_id, &block)
        subscription_id = connection.store[subscription_id] if connection.store.include?(subscription_id)

        message = Wampproto::Message::Unsubscribe.new(next_request_id, subscription_id)
        action = MessageHandler::Unsubscribe.new(message, connection)
        action.send_message(&block)
      end

      def publish(topic, options = {}, *args, **kwargs, &block)
        options = options.merge({ acknowledge: true }) if block_given?
        message = Wampproto::Message::Publish.new(next_request_id, options, topic, *args, **kwargs)

        action = MessageHandler::Publish.new(message, connection)
        action.send_message(&block)
      end

      def call(procedure, options = {}, *args, **kwargs, &handler)
        message = Wampproto::Message::Call.new(next_request_id, options, procedure, *args, **kwargs)

        MessageHandler::Call.new(message, connection).send_message(handler)
      end

      def register(procedure, handler, options = {}, &block)
        message = Wampproto::Message::Register.new(next_request_id, options, procedure)
        action = MessageHandler::Register.new(message, connection)
        action.send_message(handler, &block)
      end

      def unregister(registration_id, &block)
        registration_id = connection.store[registration_id] if connection.store.include?(registration_id)

        message = Wampproto::Message::Unregister.new(next_request_id, registration_id)
        action = MessageHandler::Unregister.new(message, connection)
        action.send_message(&block)
      end

      private

      def next_request_id
        id_gen.next
      end
    end
  end
end
