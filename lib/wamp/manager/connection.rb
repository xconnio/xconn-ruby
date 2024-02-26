# frozen_string_literal: true

require "delegate"

module Wamp
  module Manager
    # connection
    class Connection < Connection::Base
      def initialize(**kwargs)
        super
        @session = Session.new(self)
      end

      def on_message(data)
        p [:on_message, data]
        message = Message.instance_from(coder.decode(data))
        if message.instance_of? Message::Welcome

          manager = Manager::Base.instance_from(message, @session)
          manager.emit_event(message)
        else
          @session.on_message(message)
        end
      end

      def on_open
        send_hello_message
      end

      private

      def send_hello_message
        message = Message::Hello.new(@realm)
        manager = Manager::HelloEvent.new(message, self)
        manager.add_event_listener
      end
    end
  end
end
