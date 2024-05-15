# frozen_string_literal: true

module Wamp
  module MessageHandler
    # callback for unregister message
    class Unregistered < Base
      def handle
        validate_received_message

        delete_procedure store.delete(alt_store_key)

        deliver_response
      end

      def alt_store_key
        "registration_#{registration_id}"
      end

      def delete_procedure(data)
        store.delete data.fetch(:procedure)
      end

      def registration_id
        stored_data.fetch(:registration_id)
      end
    end
  end
end
