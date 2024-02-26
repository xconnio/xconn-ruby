# frozen_string_literal: true

module Wamp
  module Message
    # wamp call message
    class Call
      attr_reader :request_id, :options, :procedure, :args, :kwargs

      def initialize(request_id, options, procedure, *args, **kwargs)
        @request_id = Validate.int!("Request Id", request_id)
        @options    = Validate.hash!("Options", options)
        @procedure = Validate.string!("Procedure", procedure)
        @args       = Validate.array!("Arguments", args)
        @kwargs     = Validate.hash!("Keyword Arguments", kwargs)
      end

      def payload
        @payload = [Type::CALL, @request_id, @options, @procedure]
        @payload << @args if @kwargs.any? || @args.any?
        @payload << @kwargs if @kwargs.any?
        @payload
      end

      def self.parse(wamp_message)
        _type, request_id, options, procedure, args, kwargs = wamp_message
        args   ||= []
        kwargs ||= {}
        new(request_id, options, procedure, *args, **kwargs)
      end
    end
  end
end
