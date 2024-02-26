# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # publish message
    class Registered
      attr_reader :request_id, :registration_id

      def initialize(request_id, registration_id)
        @request_id = Validate.int!("Request Id", request_id)
        @registration_id = Validate.int!("Registration Id", registration_id)
      end

      def payload
        [Type::REGISTERED, @request_id, @registration_id]
      end

      def self.parse(wamp_message)
        _type, request_id, registration_id = wamp_message
        new(request_id, registration_id)
      end
    end
  end
end
