# frozen_string_literal: true

require_relative "event/hello"
require_relative "event/welcome"
require_relative "event/abort"
require_relative "event/goodbye"

require_relative "event/error"

require_relative "event/subscribe"
require_relative "event/subscribed"
require_relative "event/unsubscribe"
require_relative "event/unsubscribed"
require_relative "event/publish"
require_relative "event/published"
require_relative "event/event"

require_relative "event/call"
require_relative "event/result"

require_relative "event/register"
require_relative "event/registered"

require_relative "event/unregister"
require_relative "event/unregistered"

require_relative "event/invocation"

module Wamp
  module Manager
    # handles creating correct event managers
    module Event
      # methods responsbile for instantiating correct event
      module ClassMethods
        def resolve(message, session)
          klass_name = demodulize(message.class.name)
          klass = constantize("Wamp::Manager::Event::#{klass_name}")
          klass.new(message, session)
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
end
