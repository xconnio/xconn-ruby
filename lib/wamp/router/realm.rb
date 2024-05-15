# frozen_string_literal: true

module Wamp
  module Router
    # Realm
    class Realm
      attr_reader :broker, :dealer, :name, :clients

      DEALER_MESSAGES = [
        Wampproto::Message::Call,
        Wampproto::Message::Yield,
        Wampproto::Message::Register,
        Wampproto::Message::Unregister
      ].freeze

      BROKER_MESSAGES = [
        Wampproto::Message::Publish,
        Wampproto::Message::Subscribe,
        Wampproto::Message::Unsubscribe
      ].freeze

      GOODBYE_MESSAGE = Wampproto::Message::Goodbye

      def initialize(name)
        @name   = name
        @broker = Wampproto::Broker.new(id_gen)
        @dealer = Wampproto::Dealer.new(id_gen)
        @clients = {}
      end

      def attach_client(client)
        session_id = client.session_id

        clients[session_id] = client
        broker.add_session(session_id)
        dealer.add_session(session_id)
      end

      def detach_client(client)
        remove_client(client.session_id)
      end

      def clear
        clients.each { |client| remove_client(client.session_id) }
      end

      def receive_message(session_id, message)
        case message
        when *DEALER_MESSAGES then handle_dealer(session_id, message)
        when *BROKER_MESSAGES then handle_broker(session_id, message)
        when GOODBYE_MESSAGE then handle_goodbye(session_id, message)
        end
      end

      private

      def handle_dealer(session_id, message)
        send_message dealer.receive_message(session_id, message)
      end

      def handle_broker(session_id, message)
        send_message broker.receive_message(session_id, message)
      end

      def handle_goodbye(session_id, _message)
        goodbye = Wampproto::Message::Goodbye.new({}, "wamp.close.goodbye_and_out")
        send_message Wampproto::MessageWithRecipient.new(goodbye, session_id)
      end

      def send_message(message_with_receipient)
        Array(message_with_receipient).each do |object|
          client = clients[object.recipient]

          next unless client

          client.send_message object.message
        end
      end

      def id_gen
        @id_gen ||= Wampproto::IdGenerator.new
      end

      def remove_client(session_id)
        broker.remove_session(session_id)
        dealer.remove_session(session_id)
        clients.delete(session_id)
      end
    end
  end
end
