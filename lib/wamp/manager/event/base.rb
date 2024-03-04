# frozen_string_literal: true

require "delegate"

module Wamp
  module Manager
    # no:doc
    module Event
      # Base Class for Listening and Emitting events
      # Each event should base as parent class
      class Base < SimpleDelegator
        attr_reader :session

        def initialize(message, session)
          super(message)
          @session = session
        end

        def emit_event(message)
          session.emit(emit_event_name, message)
        end

        def listen_event_name
          "request_#{request_id}"
        end

        def emit_event_name
          "request_#{request_id}"
        end
      end
    end
  end
end
