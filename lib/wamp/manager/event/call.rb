# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Call Message Event
      class Call < Base
        def add_event_listener(&block) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          on_progress = options.delete(:on_progress)
          options.merge!(receive_progress: true) if on_progress

          session.on(listen_event_name) do |result, error|
            if error
              block&.call(nil, error)
            elsif result && result.details["progress"]
              on_progress.call(result)
            else
              session.off(listen_event_name)
              block&.call(result, nil)
            end
          end
          session.transmit(payload)
        end

        def emit_event(message)
          manager = Wamp::Router::Registrations.invoke(message, session)
          return manager.transmit if manager.error?

          # Invocation Manager Receives Yield Message
          manager.add_event_listener do |yield_msg|
            result = Message::Result.new(message.request_id, {}, *yield_msg.args, **yield_msg.kwargs)
            session.transmit(result.payload)
          end
        end
      end
    end
  end
end
