# frozen_string_literal: true

require_relative "realm"

module Wamp
  module Router
    # Auth
    class Authenticator
      def self.authenticate(request)
        Wampproto::Acceptor::Response.new(request.authid, "role", "secret")
      end
    end

    # Server Session
    class Client
      attr_accessor :router, :connection
      attr_reader   :acceptor, :serializer

      def initialize(serializer = Wampproto::Serializer::JSON, authenticator = Authenticator)
        @serializer = serializer
        @acceptor = Wampproto::Acceptor.new(serializer, authenticator)
      end

      def realm
        acceptor.session_details&.realm
      end

      def send_message(message)
        transmit(message)
      end

      def session_id
        acceptor.session_details&.session_id
      end

      def transmit(data)
        case data
        when Wampproto::Message::Base
          connection.on_message serializer.serialize(data)
        else
          connection.on_message data
        end
      end

      def on_message(data)
        unless acceptor.accepted?
          msg, is_welcome = acceptor.receive(data)
          transmit msg
          router.attach_client(self) if is_welcome
        end
        router.receive_message(self, serializer.deserialize(data))
      end
    end
  end
end
