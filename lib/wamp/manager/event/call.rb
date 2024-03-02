# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Call Message Event
      class Call < Base
        def add_event_listener(&block)
          session.on(listen_event_name) do |result, error|
            session.off(listen_event_name)
            block&.call(result, error)
          end
          session.transmit(payload)
        end
      end
    end
  end
end
