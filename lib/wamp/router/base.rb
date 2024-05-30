# frozen_string_literal: true

require_relative "realm"

module Wamp
  module Router
    # Router
    class Base
      attr_reader :realms

      def initialize
        @realms = {}
      end

      def add_realm(name)
        realms[name] = Realm.new(name)
      end

      def remove_realm(name)
        realms.delete(name)
      end

      def attach_client(client)
        error_message = "cannot attach client to non-existent realm #{client.realm}"
        raise Wampproto::ValueError, error_message unless realms.include?(client.realm)

        realms[client.realm].attach_client(client)
      end

      def detach_client(client)
        error_message = "cannot attach client to non-existent realm #{client.realm}"
        raise Wampproto::ValueError, error_message unless realms.include?(client.realm)

        realms[client.realm].detach_client(client)
      end

      def receive_message(client, message)
        error_message = "cannot attach client to non-existent realm #{client.realm}"
        raise Wampproto::ValueError, error_message unless realms.include?(client.realm)

        realms[client.realm].receive_message(client.session_id, message)
      end
    end
  end
end
