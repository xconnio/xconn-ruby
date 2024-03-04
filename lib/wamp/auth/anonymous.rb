# frozen_string_literal: true

module Wamp
  module Auth
    # generates wampcra authentication signature
    class Anonymous
      def initialize(details = {})
        @details = details
      end

      def details
        {}.tap do |hsh|
          hsh[:authid] = "anonymous"
          hsh[:authmethods] = ["anonymous"]
        end
      end

      def authenticate(_challenge); end
    end
  end
end
