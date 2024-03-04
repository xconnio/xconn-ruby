# frozen_string_literal: true

require_relative "base"
require_relative "subscribed"

module Wamp
  module Manager
    module Event
      # Subscribe Message Event
      class Subscribe < Base
        def subscription
          @subscription ||= Subscription.new(__getobj__, session)
        end

        def add_event_listener(listener, &block)
          session.on(listen_event_name) do |subscribed, error|
            subscription.subscription_id = subscribed.subscription_id if subscribed

            session.off(listen_event_name)
            block.call(subscribed, error) if block_given?
            add_subscribed_event_listner(subscribed, listener)
          end
          session.transmit(payload)
        end

        def listen_event_name
          "request_#{request_id}"
        end

        private

        def add_subscribed_event_listner(message, listener)
          manager = Subscribed.new(message, session)
          manager.add_event_listener(listener)
        end
      end
    end
  end
end
