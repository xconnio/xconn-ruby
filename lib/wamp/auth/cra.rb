# frozen_string_literal: true

module Wamp
  module Auth
    # generates wampcra authentication signature
    class Cra
      attr_reader :secret

      def initialize(secret, details = {})
        @secret = secret
        @details = details
      end

      def details
        {}.tap do |hsh|
          hsh[:authid] = @details.fetch(:authid)
          hsh[:authmethods] = ["wampcra"]
          hsh[:authextra] = @details.fetch(:authextra, {})
        end
      end

      def authenticate(challenge)
        signature = create_signature(challenge)
        Wamp::Message::Authenticate.new(signature)
      end

      private

      def create_signature(challenge)
        extra = challenge.extra
        hmac = OpenSSL::HMAC.new(create_drived_secret(extra), "SHA256") if extra.key?("salt")
        hmac ||= OpenSSL::HMAC.new(secret, "SHA256")

        hmac.update(extra["challenge"])

        Base64.encode64(hmac.digest).gsub("\n", "")
      end

      def create_drived_secret(extra)
        salt        = extra["salt"]
        length      = extra["keylen"]
        iterations  = extra["iterations"]

        key = OpenSSL::KDF.pbkdf2_hmac(secret, salt: salt, iterations: iterations, length: length, hash: "SHA256")
        key.unpack1("H*")
      end
    end
  end
end
