# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Registered Message Event
      class Registered < Base
        # Adding listener for invocation message
        def listen_event_name
          "registration_#{registration_id}"
        end

        def add_event_listener(handler)
          session.on(listen_event_name) do |invocation|
            details = {}
            details = { details: yield_method(invocation) } if invocation.details["receive_progress"]
            result = handler.call(*invocation.args, **invocation.kwargs, **details)
            message = Message::Yield.new(invocation.request_id, {}, result)
            session.transmit(message.payload)
          end
        end

        def yield_method(invocation)
          klass = Struct.new(:invocation, :session) do
            def progress(*args, **kwargs)
              message = Message::Yield.new(invocation.request_id, { progress: true }, *args, **kwargs)
              session.transmit(message.payload)
            end
          end
          klass.new(invocation, session)
        end
      end
    end
  end
end
