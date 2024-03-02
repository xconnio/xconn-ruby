# frozen_string_literal: true

require_relative "registered"

module Wamp
  module Manager
    module Event
      # Register Message Event
      class Register < Base
        def add_event_listener(handler, &block)
          session.transmit(payload)
          session.on(listen_event_name) do |registered, error|
            session.off(listen_event_name)
            block&.call(registered, error)

            unless error
              manager = Registered.new(registered, session)
              manager.add_event_listener(handler)
            end
          end
        end
      end
    end
  end
end
