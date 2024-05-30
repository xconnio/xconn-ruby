# frozen_string_literal: true

module Wamp
  module Type
    # Registration Type
    class Registration
      attr_reader :registration_id

      def initialize(registration_id: nil)
        @registration_id = registration_id
      end
    end
  end
end
