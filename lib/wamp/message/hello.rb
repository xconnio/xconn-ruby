# frozen_string_literal: true

require_relative "../../wamp/version"
require_relative "validate"

module Wamp
  module Message
    # Wamp Hello message
    class Hello
      def initialize(realm, details = {})
        @realm = Validate.string!("Realm", realm)
        @details = default_details.merge(parse_details(Validate.hash!("Details", details))).merge(additional_details)
      end

      def payload
        [Type::HELLO, @realm, @details]
      end

      def parse_details(hsh = {})
        details = {}
        details[:roles] = hsh.fetch(:roles, default_roles)
        details[:authid] = hsh.fetch(:authid, "")
        details[:authmethods] = [*hsh.fetch(:authmethods, "anonymous")]
        details[:authextra] = hsh.fetch(:authextra) if hsh[:authextra]
        details
      end

      private

      def default_details
        { roles: default_roles }
      end

      def default_roles
        { caller: {}, publisher: {}, subscriber: {}, callee: {} }
      end

      def additional_details
        { agent: "Ruby-Wamp-Client-#{Wamp::VERSION}" }
      end
    end
  end
end
