# frozen_string_literal: true

require_relative "../../wamp/version"
require_relative "validate"

module Wamp
  module Message
    # Wamp Hello message
    class Hello
      def initialize(realm, details = {})
        @realm = Validate.string!("Realm", realm)
        @details = default_details.merge(Validate.hash!("Details", details)).merge(additional_details)
      end

      def payload
        [Type::HELLO, @realm, @details]
      end

      private

      def default_details
        { authid: "", roles: { caller: {}, publisher: {}, subscriber: {}, callee: {} } }
      end

      def additional_details
        { agent: "Ruby-Wamp-Client-#{Wamp::VERSION}" }
      end
    end
  end
end
