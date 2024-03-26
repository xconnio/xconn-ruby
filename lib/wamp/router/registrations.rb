# frozen_string_literal: true

module Wamp
  module Router
    # Handle Procedure Registrations
    class Registrations
      @registrations = {}
      @registration_ids = {}
      class << self
        def register(message, session)
          return procedure_already_registered(message) if check_registered?(message)

          registration_id = create_or_update_registration(message, session)

          Wamp::Message::Registered.new(message.request_id, registration_id)
        end

        def check_registered?(message)
          invocation_policy = message.options.fetch(:invoke, :single)
          return @registrations.include?(message.procedure) if invocation_policy == "single"

          registration = @registrations[message.procedure]
          return false unless registration

          return true if registration[:message].options.fetch(:invoke, :single) != invocation_policy

          false
        end

        def clean_registrations(session)
          @registrations.each_key { |procedure| clean_registration(procedure, session) }
        end

        def clean_registration(procedure, session)
          registration = @registrations[procedure]
          sessions = registration[:sessions]
          if sessions.one? && sessions.include?(session)
            puts "Removing Registration #{registration[:registration_id]}, procedure: #{procedure}"
            @registrations.delete(procedure)
          elsif sessions.include?(session)
            puts "Removing Session #{session.session_id}, procedure: #{procedure}"
            sessions.delete(session)
          end
        end

        def clean_registration_by_id(registration_id, session)
          procedure = @registration_ids[registration_id]
          return unless procedure

          clean_registration(procedure, session)
        end

        def create_or_update_registration(message, session)
          registration = @registrations[message.procedure] || {}
          registration.empty? ? create_registration(message, session) : update_registration(registration, session)
        end

        def create_registration(message, session)
          registration_id = create_registration_id(message.procedure)
          @registrations[message.procedure] = {
            message: message,
            registration_id: registration_id,
            sessions: [session]
          }
          registration_id
        end

        def update_registration(registration, session)
          registration[:sessions] << session
          registration.fetch(:registration_id)
        end

        def invoke(message, caller_session)
          unless @registrations.include?(message.procedure)
            return Manager::Event.resolve(no_such_procedure(message), caller_session)
          end

          registration = @registrations.fetch(message.procedure)
          registration_id = registration[:registration_id]
          callee_session = find_session(registration)

          Wamp::Message::Invocation.new(message.request_id * 2000, registration_id, {}, *message.args, **message.kwargs)
            .then { |msg| Manager::Event.resolve(msg, callee_session) }
        end

        def find_session(registration)
          sessions = registration.fetch(:sessions)
          index = find_session_index(registration, sessions.length)
          sessions[index]
        end

        def find_session_index(registration, session_length)
          invocation_policy = registration.fetch(:message).options.fetch(:invoke, :single).intern
          index = { single: 0, first: 0, last: -1, random: rand(0..(session_length - 1)) }[invocation_policy]
          return index if index

          cycle_index = registration.fetch(:cycle_index, 0)
          registration[:cycle_index] = cycle_index < session_length - 1 ? cycle_index + 1 : 0
          cycle_index
        end

        def procedure_already_registered(message)
          Message::Error.new(Message::Type::REGISTER, message.request_id, {}, "wamp.error.procedure_already_exists")
        end

        def no_such_procedure(message)
          Message::Error.new(Message::Type::CALL, message.request_id, {}, "wamp.error.no_such_procedure")
        end

        def create_registration_id(procedure)
          id = rand(100_000..(2**53))
          if @registration_ids.include?(id)
            create_registration_id(procedure)
          else
            @registration_ids[id] = procedure
            id
          end
        end
      end
    end
  end
end
