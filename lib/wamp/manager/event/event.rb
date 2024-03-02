# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Event Message Event
      class Event < Base
        def emit_event_name
          "event_#{subscription_id}"
        end

        def emit_event(message)
          session.emit(emit_event_name, message)
        end
      end
    end
  end
end
