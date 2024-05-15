# frozen_string_literal: true

require_relative "message_handler/base"

require_relative "message_handler/hello"
require_relative "message_handler/welcome"
require_relative "message_handler/challenge"
require_relative "message_handler/goodbye"

require_relative "message_handler/subscribe"
require_relative "message_handler/subscribed"
require_relative "message_handler/unsubscribe"
require_relative "message_handler/unsubscribed"

require_relative "message_handler/publish"
require_relative "message_handler/published"
require_relative "message_handler/event"

require_relative "message_handler/call"
require_relative "message_handler/result"

require_relative "message_handler/register"
require_relative "message_handler/registered"
require_relative "message_handler/unregister"
require_relative "message_handler/unregistered"

require_relative "message_handler/invocation"
require_relative "message_handler/yield"

require_relative "message_handler/error"

require_relative "message_handler/api"

module Wamp
  # routes messages
  module MessageHandler
    # instantiate correct handler
    module ClassMethods
      def resolve(data, connection)
        # return handle_when_not_joined(data, connection) unless connection.joiner.joined?

        message = connection.joiner.serializer.deserialize(data)
        klass_name = demodulize(message.class.name)
        klass = constantize("Wamp::MessageHandler::#{klass_name}")
        klass.new(message, connection)
      end

      def handle_when_not_joined(data, connection)
        authenticate = connection.joiner.receive(data) # maybe welcome message then state should be joined
        connection.transmit authenticate unless connection.joiner.joined?
        connection.executor.call(connection.api) if connection.joiner.joined?
        Struct.new(:handle).new
      end

      def from(message, connection)
        klass_name = demodulize(message.class.name)
        klass = constantize("Wamp::MessageHandler::#{klass_name}")
        klass.new(message, connection)
      end

      def demodulize(path)
        path = path.to_s
        if i = path.rindex("::") # rubocop:disable Lint/AssignmentInCondition
          path[(i + 2), path.length]
        else
          path
        end
      end

      def constantize(camel_cased_word)
        Object.const_get(camel_cased_word)
      end
    end
    extend ClassMethods
  end
end
