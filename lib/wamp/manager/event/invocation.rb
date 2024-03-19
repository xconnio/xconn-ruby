# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Unregistered Message Event
      class Invocation < Base
        def add_event_listener(&callback)
          session.on(listen_event_name) do |yield_msg|
            session.off(listen_event_name)
            callback.call(yield_msg)
          end
          transmit
        end

        def emit_event_name
          "registration_#{registration_id}"
        end
      end
    end
  end
end
