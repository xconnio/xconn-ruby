# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # wamp call message
    class Result
      attr_reader :request_id, :details, :procedure, :args, :kwargs

      def initialize(request_id, details, *args, **kwargs)
        @request_id = Validate.int!("Request Id", request_id)
        @details    = Validate.hash!("Details", details)
        @args       = Validate.array!("Arguments", args)
        @kwargs     = Validate.hash!("Keyword Arguments", kwargs)
      end

      def payload
        @payload = [Type::RESULT, @request_id, @details]
        @payload << @args if @kwargs.any? || @args.any?
        @payload << @kwargs if @kwargs.any?
        @payload
      end

      def self.parse(wamp_message)
        _type, request_id, details, args, kwargs = wamp_message
        args   ||= []
        kwargs ||= {}
        new(request_id, details, *args, **kwargs)
      end
    end
  end
end
