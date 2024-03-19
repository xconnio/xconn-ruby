# frozen_string_literal: true

require_relative "../../wamp/version"
require_relative "validate"

module Wamp
  module Message
    # Wamp Hello message
    class Hello
      attr_reader :realm, :details

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

      def self.parse(wamp_message)
        _type, realm, details = wamp_message
        new(realm, details)
      end

      private

      def default_details
        { roles: default_roles }
      end

      def default_roles
        { caller: {
          features: { call_canceling: true, caller_identification: true, progressive_call_results: true }
        }, publisher: {}, subscriber: {},
          callee: {

            features: { call_canceling: true, progressive_call_results: true, registration_revocation: true,
                        caller_identification: true }
          } }
      end

      def additional_details
        { agent: "Ruby-Wamp-Client-#{Wamp::VERSION}" }
      end
    end
  end
end
