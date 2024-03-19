# frozen_string_literal: true

module Wamp
  module Router
    module Session
      # handle session establishment
      class Base
        REALMS = ["realm1"].freeze
        attr_reader :hello

        def initialize(hello)
          @hello = hello
        end

        def authenticate(message)
          return protocol_violation if message.instance_of?(Message::Hello)

          return unless auth_method == "ticket"

          return welcome_message if message.signature == "hello"

          send_abort
        end

        def send_abort
          Message::Abort.new({ message: "Not Authorized" }, "wamp.error.not_authorized")
        end

        def protocol_violation
          Message::Abort.new(
            { message: "Received HELLO message after session was established" },
            "wamp.error.protocol_violation"
          )
        end

        def handle_auth
          realm = find_realm(hello.realm)
          return realm_missing unless realm

          handle_correct_auth
        end

        def handle_correct_auth
          if auth_method == "ticket"
            Message::Challenge.new("ticket", {})
          else
            welcome_message
          end
        end

        def auth_method
          authmethods = [*hello.details[:authmethods]]
          authmethods.first
        end

        def welcome_message
          Message::Welcome.new(Router.create_identifier, { roles: { broker: {} } })
        end

        def realm_missing
          Wamp::Message::Abort.new(
            { message: "The realm does not exists." }, "wamp.error.no_such_realm"
          )
        end

        def find_realm(realm)
          realm if REALMS.include?(realm)
        end
      end
    end
  end
end
