# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Hello Message Event
      class Hello < Base
        def add_event_listener
          session.transmit(payload)
        end

        def listen_event_name
          :join
        end
      end
    end
  end
end
