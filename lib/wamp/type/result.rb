# frozen_string_literal: true

module Wamp
  module Type
    # Result Type
    class Result
      attr_reader :args, :kwargs, :details

      def initialize(args: [], kwargs: {}, details: {})
        @args = args
        @kwargs = kwargs
        @details = details
      end
    end
  end
end
