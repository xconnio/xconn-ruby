# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # Wamp Authenticate message
    class Authenticate
      attr_reader :signature, :extra

      def initialize(signature, extra = {})
        @signature = Validate.string!("Signature", signature)
        @extra = Validate.hash!("Extra", extra)
      end

      def payload
        [Type::AUTHENTICATE, signature, extra]
      end

      def self.parse(wamp_message)
        _type, signature, extra = wamp_message
        new(signature, extra)
      end
    end
  end
end
