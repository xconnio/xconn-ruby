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
            result = handler.call(*invocation.args, **invocation.kwargs)
            message = Message::Yield.new(invocation.request_id, {}, result)
            session.transmit(message.payload)
          end
        end
      end
    end
  end
end
