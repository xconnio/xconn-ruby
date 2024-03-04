# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # Unsubscribed message
    class Unsubscribed
      attr_reader :request_id

      def initialize(request_id)
        @request_id = Validate.int!("Request Id", request_id)
      end

      def payload
        [Type::UNSUBSCRIBED, @request_id]
      end

      def self.parse(wamp_message)
        _type, request_id = Validate.length!(wamp_message, 2)
        new(request_id)
      end
    end
  end
end
