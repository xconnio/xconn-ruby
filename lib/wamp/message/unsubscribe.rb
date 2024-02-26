# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # abort message
    class Unsubscribe
      def initialize(request_id, subscription_id)
        @request_id = Validate.int!("Request Id", request_id)
        @subscription_id = Validate.int!("Subscription Id", subscription_id)
      end

      def payload
        [Type::UNSUBSCRIBE, @request_id, @subscription_id]
      end

      def self.parse(wamp_message)
        _type, request_id, subscription_id = Validate.length!(wamp_message, 3)
        new(request_id, subscription_id)
      end
    end
  end
end
