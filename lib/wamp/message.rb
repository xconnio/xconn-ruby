# frozen_string_literal: true

require_relative "message/hello"
require_relative "message/welcome"
require_relative "message/abort"
require_relative "message/challenge"
require_relative "message/authenticate"

require_relative "message/goodbye"
require_relative "message/error"

require_relative "message/subscribe"
require_relative "message/subscribed"
require_relative "message/unsubscribe"
require_relative "message/unsubscribed"
require_relative "message/event"

require_relative "message/publish"
require_relative "message/published"

require_relative "message/call"
require_relative "message/cancel"
require_relative "message/result"

require_relative "message/register"
require_relative "message/registered"
require_relative "message/unregister"
require_relative "message/unregistered"

require_relative "message/invocation"
require_relative "message/interrupt"
require_relative "message/yield"

module Wamp
  # message root
  module Message
    module Type
      HELLO         = 1
      WELCOME       = 2
      ABORT         = 3
      CHALLENGE     = 4
      AUTHENTICATE  = 5
      GOODBYE       = 6

      ERROR = 8

      PUBLISH   = 16
      PUBLISHED = 17

      SUBSCRIBE     = 32
      SUBSCRIBED    = 33
      UNSUBSCRIBE   = 34
      UNSUBSCRIBED  = 35
      EVENT         = 36

      CALL    = 48
      CANCEL  = 49
      RESULT  = 50

      REGISTER      = 64
      REGISTERED    = 65
      UNREGISTER    = 66
      UNREGISTERED  = 67
      INVOCATION    = 68
      INTERRUPT     = 69
      YIELD         = 70
    end

    HANDLER = {
      Type::HELLO => Hello,
      Type::WELCOME => Welcome,
      Type::ABORT => Abort,
      Type::CHALLENGE => Challenge,
      Type::AUTHENTICATE => Authenticate,
      Type::GOODBYE => Goodbye,

      Type::ERROR => Error,

      Type::SUBSCRIBE => Subscribe,
      Type::SUBSCRIBED => Subscribed,
      Type::UNSUBSCRIBE => Unsubscribe,
      Type::UNSUBSCRIBED => Unsubscribed,

      Type::PUBLISH => Publish,
      Type::PUBLISHED => Published,
      Type::EVENT => Event,

      Type::CALL => Call,
      Type::CANCEL => Cancel,
      Type::RESULT => Result,

      Type::REGISTER => Register,
      Type::REGISTERED => Registered,
      Type::UNREGISTER => Unregister,
      Type::UNREGISTERED => Unregistered,

      Type::INTERRUPT => Interrupt,
      Type::INVOCATION => Invocation,

      Type::YIELD => Yield
    }.freeze

    def self.resolve(wamp_message)
      type, = Validate.array!("Wamp Message", wamp_message)
      begin
        HANDLER[type].parse(wamp_message)
      rescue StandardError => e
        p wamp_message
        raise e
      end
    end
  end
end
