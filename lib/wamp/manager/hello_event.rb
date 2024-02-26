# frozen_string_literal: true

require "delegate"

module Wamp
  module Manager
    # handles hello event
    class Base < SimpleDelegator
      attr_reader :session

      def initialize(message, session)
        super(message)
        @session = session
      end

      def emit_event(message)
        session.emit(emit_event_name, message)
      end

      def self.instance_from(message, session)
        klass_name = demodulize(message.class.name)
        klass = constantize("Wamp::Manager::#{klass_name}Event")
        klass.new(message, session)
      end

      def self.demodulize(path)
        path = path.to_s
        if i = path.rindex("::")
          path[(i + 2), path.length]
        else
          path
        end
      end

      def self.constantize(camel_cased_word)
        Object.const_get(camel_cased_word)
      end
    end

    # message
    class HelloEvent < Base
      def add_event_listener
        session.transmit(payload)
      end

      def emit_event_name
        raise RuntimeError
      end

      def listen_event_name
        :join
      end
    end

    class WelcomeEvent < Base
      def emit_event_name
        :join
      end

      def emit_event(_message)
        session.emit(emit_event_name, @session)
      end
    end

    class AbortEvent < Base
      def emit_event_name
        :close
      end

      def emit_event(message)
        session.emit(emit_event_name, message)
        session.close(1000, message.reason)
      end
    end

    class GoodbyeEvent < AbortEvent
    end

    class ErrorEvent < Base
      def emit_event_name
        "request_#{request_id}"
      end

      def emit_event(message)
        session.emit(emit_event_name, nil, message)
      end
    end

    class SubscribeEvent < Base
      def emit_event_name
        raise RuntimeError
      end

      def add_event_listener(listener, &block)
        session.on(listen_event_name) do |subscribed, error|
          session.off(listen_event_name)
          block.call(subscribed, error) if block_given?
          manager = SubscribedEvent.new(subscribed, session)
          manager.add_event_listener(listener)
        end
        session.transmit(payload)
      end

      def listen_event_name
        "request_#{request_id}"
      end
    end

    class SubscribedEvent < Base
      def emit_event_name
        "request_#{request_id}"
      end

      def emit_event(message)
        session.emit(emit_event_name, message)
      end

      def add_event_listener(listener)
        session.on(listen_event_name, listener)
      end

      def listen_event_name
        "event_#{subscription_id}"
      end
    end

    class EventEvent < Base
      def emit_event_name
        "event_#{subscription_id}"
      end

      def emit_event(message)
        session.emit(emit_event_name, message)
      end

      def listen_event_name
        raise NotImplementedError
      end
    end

    class PublishEvent < Base
      def emit_event_name
        raise NotImplementedError
      end

      def add_event_listener(&block)
        session.transmit(payload)
        return unless block_given?

        session.on(listen_event_name) do |publication|
          session.off(listen_event_name)
          block.call(publication, nil)
        end
      end

      def listen_event_name
        "request_#{request_id}"
      end
    end

    class PublishedEvent < Base
      def emit_event_name
        "request_#{request_id}"
      end

      def emit_event(message)
        session.emit(emit_event_name, message)
      end

      def listen_event_name
        "request_#{request_id}"
      end
    end

    # Call Message Decorator
    class CallEvent < Base
      def listen_event_name
        "request_#{request_id}"
      end

      def add_event_listener(&block)
        session.on(listen_event_name) do |result, error|
          session.off(listen_event_name)
          block.call(result, error)
        end
        session.transmit(payload)
      end
    end

    # Call Result Message Decorator
    class ResultEvent < Base
      def emit_event_name
        "request_#{request_id}"
      end
    end

    # Unregister Messagae Decorator
    class UnregisterEvent < Base
      def listen_event_name
        "request_#{request_id}"
      end

      def add_event_listener(&block)
        session.transmit(payload)
        session.on(listen_event_name) do |unregistered, error|
          block&.call(unregistered, error)
        end
      end
    end

    # Register Message Decorator
    class RegisterEvent < Base
      def listen_event_name
        "request_#{request_id}"
      end

      def add_event_listener(handler, &block)
        session.transmit(payload)
        session.on(listen_event_name) do |registered, error|
          session.off(listen_event_name)
          manager = RegisteredEvent.new(registered, session)
          manager.add_event_listener(handler)
          block.call(registered, error)
        end
      end
    end

    # Registered Message Decorator
    class RegisteredEvent < Base
      def emit_event_name
        "request_#{request_id}"
      end

      # Adding listener for invocation message
      def listen_event_name
        "registration_#{registration_id}"
      end

      def add_event_listener(handler)
        session.on(listen_event_name) do |invocation|
          result = handler.call(invocation)
          message = Message::Yield.new(invocation.request_id, {}, result)
          session.transmit(message.payload)
        end
      end
    end

    # Invocation Message Decorator
    class InvocationEvent < Base
      def emit_event_name
        "registration_#{registration_id}"
      end
    end
  end
end
