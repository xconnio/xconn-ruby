# frozen_string_literal: true

module Wamp
  module Manager
    module Event
      # Authenticate
      class Authenticate < Base
        def emit_event_name
          :authenticate
        end
      end
    end
  end
end
