# frozen_string_literal: true

require_relative "abort"

module Wamp
  module Manager
    module Event
      # Abort Message Event
      class Goodbye < Abort
        def emit_event(_message)
          reply = Message::Goodbye.new({}, "wamp.close.goodbye_and_out")
          session.transmit(reply.payload)
          super
        end
      end
    end
  end
end
