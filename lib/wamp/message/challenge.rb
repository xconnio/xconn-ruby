# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # Wamp Challenge message
    class Challenge
      attr_reader :auth_method, :extra

      def initialize(auth_method, extra = {})
        @auth_method = Validate.string!("AuthMethod", auth_method)
        @extra = Validate.hash!("Extra", extra)
      end

      def payload
        [Type::CHALLENGE, auth_method, extra]
      end

      def self.parse(wamp_message)
        _type, auth_method, extra = wamp_message
        new(auth_method, extra)
      end
    end
  end
end
