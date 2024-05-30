# frozen_string_literal: true

module Wamp
  module MessageHandler
    # Registered callback
    class Registered < Base
      def handle
        validate_received_message

        store[alt_store_key] = { handler: stored_data.fetch(:handler), procedure: stored_data.fetch(:procedure) }
        store_procedure

        deliver_response(response)
      end

      def response
        Type::Registration.new(registration_id: message.registration_id)
      end

      def alt_store_key
        "registration_#{message.registration_id}"
      end

      def store_procedure
        procedure = stored_data.fetch(:procedure)
        store[procedure] = message.registration_id
      end
    end
  end
end
