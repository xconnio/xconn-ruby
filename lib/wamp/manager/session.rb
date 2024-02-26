# frozen_string_literal: true

require "forwardable"

module Wamp
  module Manager
    # handles session
    class Session
      extend Forwardable

      def initialize(connection)
        @connection = connection
      end

      def subscribe(topic, handler, options = {}, &block)
        message = Message::Subscribe.new(next_request_id, options, topic)
        Manager::SubscribeEvent.new(message, self).add_event_listener(handler, &block)
      end

      def publish(topic, options, *args, **kwargs, &block)
        options = options.merge({ acknowledge: true }) if block_given?
        message = Message::Publish.new(next_request_id, options, topic, *args, **kwargs)
        Manager::PublishEvent.new(message, self).add_event_listener(&block)
      end

      def call(procedure, options = {}, *args, **kwargs, &block)
        message = Message::Call.new(next_request_id, options, procedure, *args, **kwargs)
        Manager::CallEvent.new(message, self).add_event_listener(&block)
      end

      def register(procedure, handler, options = {}, &block)
        message = Message::Register.new(next_request_id, options, procedure)
        Manager::RegisterEvent.new(message, self).add_event_listener(handler, &block)
      end

      # def unregister(registration_id, &block)
      #   message = Message::Unregister.new(next_request_id, registration_id)
      #   Manager::UnregisterEvent.new(message, self).add_event_listener(&block)
      # end

      def on_message(message)
        manager = Manager::Base.instance_from(message, self)
        manager.emit_event(message)
      end

      private

      def next_request_id
        @next_request_id = create_request_id_generator unless defined?(@next_request_id)
        @next_request_id.call
      end

      def create_request_id_generator
        request_id = 0
        -> { request_id += 1 }
      end

      def_delegators :@connection, :emit, :on, :close, :transmit, :my_listeners
      def_delegator :@connection, :remove_all_listeners, :off
    end
  end
end
