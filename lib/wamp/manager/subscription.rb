# frozen_string_literal: true

module Wamp
  module Manager
    # User facing subscripiton record
    class Subscription
      attr_accessor :subscription_id
      attr_reader :message, :session

      def initialize(message, session, subscription_id = nil)
        @message = message
        @session = session
        @subscription_id = subscription_id
      end

      def subscribed?
        !!subscription_id
      end

      def unsubscribe(&callback)
        return false unless subscribed?

        message = Wamp::Message::Unsubscribe.new(next_request_id, subscription_id)
        manager = Wamp::Manager::Event::Unsubscribe.new(message, session)
        manager.add_event_listener(callback)
      end

      def next_request_id
        case message
        when Wamp::Message::Subscribe
          session.create_request_id
        when Wamp::Message::Unsubscribe
          message.request_id
        end
      end
    end
  end
end
