# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Unregister Message Event
      class Unregister < Base
        def add_event_listener(&block)
          session.transmit(payload)
          session.on(listen_event_name) do |unregistered, error|
            block&.call(unregistered, error)
          end
        end
      end
    end
  end
end
