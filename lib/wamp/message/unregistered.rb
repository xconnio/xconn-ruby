# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # unregistered message
    class Unregistered
      attr_reader :request_id

      def initialize(request_id)
        @request_id = Validate.int!("Request Id", request_id)
      end

      def payload
        [Type::UNREGISTERED, @request_id]
      end

      def self.parse(wamp_message)
        _type, request_id = wamp_message
        new(request_id)
      end
    end
  end
end
