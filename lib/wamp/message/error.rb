# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # abort message
    class Error
      attr_reader :message_type, :request_id, :details, :error

      def initialize(message_type, request_id, details, error)
        @message_type = Validate.int!("Message Type", message_type)
        @request_id = Validate.int!("Request Id", request_id)
        @details = Validate.hash!("Details", details)
        @error = Validate.string!("Error", error)
      end

      def payload
        [Type::ERROR, @message_type, @request_id, @details, @error]
      end

      def self.parse(wamp_message)
        _type, message_type, request_id, details, error = Validate.length!(wamp_message, 5)
        new(message_type, request_id, details, error)
      end
    end
  end
end
