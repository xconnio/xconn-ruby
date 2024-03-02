# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Unregistered Message Event
      class Invocation < Base
        def emit_event_name
          "registration_#{registration_id}"
        end
      end
    end
  end
end
