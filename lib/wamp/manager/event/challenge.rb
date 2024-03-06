# frozen_string_literal: true

require_relative "base"
require "openssl"

module Wamp
  module Manager
    module Event
      # Welcome Message Event
      class Challenge < Base
        def emit_event_name
          :challenge
        end

        def emit_event(challenge)
          session.emit(emit_event_name, challenge)
          send_authenticate(session.authenticate(challenge))
        end

        def send_authenticate(authenticate)
          session.transmit(authenticate.payload)
        end
      end
    end
  end
end
