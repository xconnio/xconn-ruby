# frozen_string_literal: true

require_relative "base"
require_relative "../../router"

module Wamp
  module Manager
    module Event
      # Hello Message Event
      class Hello < Base
        def add_event_listener
          session.transmit(payload)
        end

        def emit_event(hello)
          session.emit(:authenticate, hello) # handle second hello message
          auth_session = Wamp::Router::Session::Base.new(hello)
          message = update_session_id_and_return(auth_session.handle_auth)
          session.transmit(message.payload)

          session.on(:authenticate) do |authenticate|
            welcome_or_error = update_session_id_and_return(auth_session.authenticate(authenticate))
            session.transmit(welcome_or_error.payload)
          end
        end

        def update_session_id_and_return(message)
          session.session_id = message.session_id if message.respond_to?(:session_id) # welcome message
          message
        end

        def listen_event_name
          :join
        end
      end
    end
  end
end
