# frozen_string_literal: true

# [8, 32, 123, {}, "wamp.error.not_authorized"]
# [8, 34, 123, {}, "wamp.error.no_such_subscription"]
# [8, 16, 123, {}, "wamp.error.not_authorized"]
# [8, 64, 123, {}, "wamp.error.procedure_already_exists"]
# [8, 66, 123, {}, "wamp.error.no_such_registration]
# [8, 68, 123, {}, "com.myapp.error.object_write_protected", ["Object is write protected."], {"severity": 3}]
# [8, 48, 123, {}, "com.myapp.error.object_write_protected", ["Object is write protected."], {"severity": 3}]
module Wamp
  module Type
    # Error Type
    class Error
      attr_reader :uri, :args, :kwargs, :details

      def initialize(uri:, args: [], kwargs: {}, details: {})
        @uri = uri
        @args = args
        @kwargs = kwargs
        @details = details
      end
    end
  end
end
