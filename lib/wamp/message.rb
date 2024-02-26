# frozen_string_literal: true

require_relative "message/hello"
require_relative "message/welcome"
require_relative "message/abort"
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
require_relative "message/result"

require_relative "message/register"
require_relative "message/registered"
require_relative "message/unregister"
require_relative "message/unregistered"

require_relative "message/invocation"

require_relative "message/yield"

module Wamp
  # message root
  module Message
    module Type
      HELLO   = 1
      WELCOME = 2
      ABORT   = 3
      GOODBYE = 6

      ERROR = 8

      PUBLISH   = 16
      PUBLISHED = 17

      SUBSCRIBE     = 32
      SUBSCRIBED    = 33
      UNSUBSCRIBE   = 34
      UNSUBSCRIBED  = 35
      EVENT         = 36

      CALL    = 48
      RESULT  = 50

      REGISTER      = 64
      REGISTERED    = 65
      UNREGISTER    = 66
      UNREGISTERED  = 67
      INVOCATION    = 68
      YIELD         = 70
    end

    HANDLER = {
      Type::HELLO => Hello,
      Type::WELCOME => Welcome,
      Type::ABORT => Abort,
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
      Type::RESULT => Result,

      Type::REGISTER => Register,
      Type::REGISTERED => Registered,
      Type::UNREGISTER => Unregister,
      Type::UNREGISTERED => Unregistered,

      Type::INVOCATION => Invocation
    }.freeze

    def self.instance_from(wamp_message)
      type, = Validate.array!("Wamp Message", wamp_message)
      HANDLER[type].parse(wamp_message)
    end
  end
end
