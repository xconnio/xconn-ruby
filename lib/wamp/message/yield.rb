# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # yield message
    class Yield
      attr_reader :request_id, :options, :args, :kwargs

      def initialize(request_id, options, *args, **kwargs)
        @request_id = Validate.int!("Request Id", request_id)
        @options = Validate.hash!("Options", options)
        @args = Validate.array!("Arguments", args)
        @kwargs = Validate.hash!("Keyword Arguments", kwargs)
      end

      def payload
        @payload = [Type::YIELD, request_id, options]
        @payload << args if kwargs.any? || args.any?
        @payload << kwargs if kwargs.any?
        @payload
      end

      def self.parse(wamp_message)
        _type, request_id, options, args, kwargs = wamp_message
        args   ||= []
        kwargs ||= {}
        new(request_id, options, *args, **kwargs)
      end
    end
  end
end
