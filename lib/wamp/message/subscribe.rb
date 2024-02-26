# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # abort message
    class Subscribe
      attr_reader :request_id, :options, :topic

      def initialize(request_id, options, topic)
        @request_id = Validate.int!("Request Id", request_id)
        @options = Validate.hash!("Options", options)
        @topic = Validate.string!("Topic", topic)
      end

      def payload
        [Type::SUBSCRIBE, @request_id, @options, @topic]
      end
    end
  end
end
