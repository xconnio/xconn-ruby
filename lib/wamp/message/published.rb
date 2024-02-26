# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # published message
    class Published
      attr_reader :request_id, :publication_id

      def initialize(request_id, publication_id)
        @request_id     = Validate.int!("Request Id", request_id)
        @publication_id = Validate.int!("Publication Id", publication_id)
      end

      def payload
        [Type::PUBLISHED, request_id, publication_id]
      end

      def self.parse(wamp_message)
        _type, request_id, publication_id = Validate.length!(wamp_message, 3)
        new(request_id, publication_id)
      end
    end
  end
end
