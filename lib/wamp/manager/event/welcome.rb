# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Welcome Message Event
      class Welcome < Base
        def emit_event_name
          :join
        end

        def emit_event(welcome)
          session.session_id = welcome.session_id
          session.emit(emit_event_name, session)
        end
      end
    end
  end
end
