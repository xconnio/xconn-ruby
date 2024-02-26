# frozen_string_literal: true

require_relative "validate"

module Wamp
  module Message
    # abort message
    class Abort
      attr_reader :details, :reason, :args, :kwargs

      def initialize(details, reason, *args, **kwargs)
        @details = Validate.hash!("Details", details)
        @reason = Validate.string!("Reason", reason)
        @args = Validate.array!("Arguments", args)
        @kwargs = Validate.hash!("Keyword Arguments", kwargs)
      end

      def payload
        @payload = [Type::ABORT, @details, @reason]
        @payload << @args if @kwargs.any? || @args.any?
        @payload << @kwargs if @kwargs.any?
        @payload
      end

      def self.parse(wamp_message)
        _type, details, reason, args, kwargs = wamp_message
        args   ||= []
        kwargs ||= {}
        new(details, reason, *args, **kwargs)
      end
    end
  end
end
