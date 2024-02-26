# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # publish message
    class Publish
      attr_reader :request_id, :options, :topic, :args, :kwargs

      def initialize(request_id, options, topic, *args, **kwargs)
        @request_id = Validate.int!("Request Id", request_id)
        @options    = Validate.hash!("Options", options)
        @topic      = Validate.string!("Topic", topic)
        @args       = Validate.array!("Arguments", args)
        @kwargs     = Validate.hash!("Keyword Arguments", kwargs)
      end

      def payload
        @payload = [Type::PUBLISH, @request_id, @options, @topic]
        @payload << @args if @kwargs.any? || @args.any?
        @payload << @kwargs if @kwargs.any?
        @payload
      end

      def self.parse(wamp_message)
        _type, request_id, options, topic, args, kwargs = wamp_message
        args   ||= []
        kwargs ||= {}
        new(request_id, options, topic, *args, **kwargs)
      end
    end
  end
end
