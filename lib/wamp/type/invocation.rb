# frozen_string_literal: true

module Wamp
  module Type
    # Invocation Type
    class Invocation
      attr_reader :args, :kwargs, :details

      def initialize(args: [], kwargs: {}, details: {})
        @args = args
        @kwargs = kwargs
        @details = details
      end
    end
  end
end
