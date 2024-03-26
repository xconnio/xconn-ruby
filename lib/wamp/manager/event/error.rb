# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Welcome Message Event
      class Error < Base
        def emit_event_name
          "request_#{request_id}"
        end

        def emit_event(message)
          session.emit(emit_event_name, nil, message)

          begin
            raise message.error if message.error
          rescue StandardError => e
            puts "Error: #{e.message}"
          end
        end

        def error?
          true
        end
      end
    end
  end
end
