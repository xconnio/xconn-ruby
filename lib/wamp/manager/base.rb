# frozen_string_literal: true

require_relative "event"
require_relative "subscription"

module Wamp
  module Manager
    # no:doc
    class Base
      include WebSocket::Driver::EventEmitter
      attr_reader :session

      def initialize(options = {})
        super()
        @options = options
        @session = Session.new(self)
      end

      def transmit(data); end

      def on_message(message)
        manager = Manager::Event.resolve(message, session)
        manager.emit_event(message)
      end

      def auth
        @options.fetch(:auth, Auth::Anonymous.new)
      end

      def run
        message = Message::Hello.new("realm1")
        manager = Manager::Event::Hello.new(message, session)
        manager.add_event_listener # adds on :join event listener
      end

      def authenticate(challenge)
        auth.authenticate(challenge)
      end
    end
  end
end
