# frozen_string_literal: true

module Wamp
  module Type
    # Subscription Type
    class Subscription
      attr_reader :subscription_id

      def initialize(subscription_id: nil)
        @subscription_id = subscription_id
      end
    end
  end
end
