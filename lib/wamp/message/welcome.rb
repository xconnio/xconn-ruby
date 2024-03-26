# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # welcome message
    class Welcome
      attr_reader :session_id, :details

      def initialize(session_id, details = {})
        @session_id = Validate.int!("Session Id", session_id)
        @details = Validate.hash!("Details", details)
      end

      def payload
        [Type::WELCOME, @session_id, @details]
      end

      def self.parse(wamp_message)
        _type, session_id, details = wamp_message
        new(session_id, details)
      end
    end
  end
end
