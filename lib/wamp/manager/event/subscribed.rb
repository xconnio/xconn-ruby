# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Subscribed Message Event
      class Subscribed < Base
        def add_event_listener(listener)
          session.on(listen_event_name) do |event|
            listener.call(*event.args, **event.kwargs)
          end
        end

        def emit_event_name
          "request_#{request_id}"
        end

        def listen_event_name
          "event_#{subscription_id}"
        end
      end
    end
  end
end
