# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Unsubscribe Message Event
      class Unsubscribe < Base
        def add_event_listener(handler)
          session.on(listen_event_name) do |unsubscribed, error|
            session.off(listen_event_name)
            handler&.call(unsubscribed, error)
            remove_event_listening
          end
          session.transmit(payload)
        end

        def remove_event_listening
          session.off(clear_event_name)
        end

        def clear_event_name
          "event_#{subscription_id}"
        end
      end
    end
  end
end
