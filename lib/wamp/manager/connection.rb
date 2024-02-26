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

      def run
        on(:join) do |session|
          p "Welcome Message received: #{session}"

          # handler = ->(m) { p [:handler, m] }
          # session.subscribe("com.hello.world", handler) do |subscribed|
          #   p [:subscribed, subscribed]
          # end

          # session.subscribe("com.hello.world2", handler) do |subscribed|
          #   p [:subscribed2, subscribed]
          # end

          # session.publish("com.hello.world3", {}, 1, 2, name: "Ismail") do |publication|
          #   p [:acknowledge, publication]
          # end

          # session.call("com.world2", {}, "a", "b", name: "Ismail") do |result, error|
          #   p [:result, result, error]
          # end

          hello_world = ->(*_args) { "ABC" }

          session.register("call.me", hello_world) do |registered, error|
            p [:registered, registered, error]
          end
          session.call("call.me", {}, "a", "b", name: "Ismail") do |r, e|
            p [:registerde_call, r, e]
          end
        end
        super
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
