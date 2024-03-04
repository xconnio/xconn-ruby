# frozen_string_literal: true

require_relative "event"
require_relative "subscription"

module Wamp
  module Manager
    # no:doc
    class Base
      include WebSocket::Driver::EventEmitter
      attr_reader :session

      def initialize
        super
        @session = Session.new(self)
      end

      def transmit(data); end

      def on_message(message)
        manager = Manager::Event.resolve(message, session)
        manager.emit_event(message)
      end

      def run
        message = Message::Hello.new("realm1")
        manager = Manager::Event::Hello.new(message, session)
        manager.add_event_listener # adds on :join event listener
      end
    end
  end
end
