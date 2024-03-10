# frozen_string_literal: true

module Wamp
  module Auth
    # generates ticket authentication signature
    class Ticket
      attr_reader :secret

      def initialize(secret, details = {})
        @secret = secret
        @details = details
      end

      def details
        {}.tap do |hsh|
          hsh[:authid] = @details.fetch(:authid)
          hsh[:authmethods] = ["ticket"]
          hsh[:authextra] = @details.fetch(:authextra, {})
        end
      end

      def authenticate(challenge)
        signature = create_signature(challenge)
        Wamp::Message::Authenticate.new(signature)
      end

      private

      def create_signature(_challenge)
        secret
      end
    end
  end
end
