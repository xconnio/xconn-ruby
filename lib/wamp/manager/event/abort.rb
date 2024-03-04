# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Abort Message Event
      class Abort < Base
        def emit_event_name
          :close
        end

        def emit_event(message)
          session.emit(emit_event_name, message)
          session.close(1000, message.reason)
        end
      end
    end
  end
end
