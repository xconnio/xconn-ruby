# frozen_string_literal: true

module Wamp
  module Type
    # Invocation Type
    class Invocation
      attr_writer :connection, :request_id
      attr_reader :args, :kwargs, :details

      def initialize(args: [], kwargs: {}, details: {})
        @args = args
        @kwargs = kwargs
        @details = details
      end

      def progress(result)
        @connection.transmit @connection.session.send_message(response(result))
      end

      def response(result)
        Wampproto::Message::Yield.new(@request_id, result.details, *result.args, **result.kwargs)
      end
    end
  end
end
