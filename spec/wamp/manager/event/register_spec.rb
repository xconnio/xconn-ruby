# frozen_string_literal: true

RSpec.describe Wamp::Manager::Event::Register do
  let(:connection) { Wamp::Manager::Base.new }
  let(:args) { [2, 3] }
  let(:sum) { 5 }
  let(:session) { connection.session }
  let(:request_id) { 1 }
  let(:registration_id) { 100 }
  let(:register_message) { Wamp::Message::Register.new(request_id, {}, "com.ruby.method") }
  let(:register_event) { Wamp::Manager::Event::Register.new(register_message, session) }
  let(:registered_message) { Wamp::Message::Registered.new(request_id, registration_id) }
  let(:registered_event) { Wamp::Manager::Event::Registered.new(registered_message, session) }

  let(:call_message) { Wamp::Message::Call.new(request_id + 1, {}, register_message.procedure, *args) }
  let(:call_event) { Wamp::Manager::Event::Call.new(call_message, session) }

  let(:invocation_message) { Wamp::Message::Invocation.new(request_id + 2, registration_id, {}, *call_message.args) }
  let(:yield_message) { Wamp::Message::Yield.new(request_id + 2, {}, sum) }

  let(:result_message) { Wamp::Message::Result.new(request_id + 1, {}, *yield_message.args) }

  context "success" do
    it "register and call" do
      expect(connection).to receive(:transmit).with(register_message.payload)
      handler = lambda do |m, n|
        m + n
      end
      session.register(register_message.procedure, handler, {})

      expect(session).to receive(:emit).with(register_event.listen_event_name,
                                             Wamp::Message::Registered).and_call_original
      session.on_message(registered_message) # router sends this message on successful registration

      expect(connection).to receive(:transmit).with(call_message.payload)
      session.call(call_message.procedure, {}, *call_message.args) do |result|
        expect(result.args).to include(sum)
      end

      expect(connection).to receive(:transmit).with(yield_message.payload)
      expect(handler).to receive(:call).with(*call_message.args).and_call_original

      expect(session).to receive(:emit).with(registered_event.listen_event_name,
                                             Wamp::Message::Invocation).and_call_original
      session.on_message(invocation_message) # invocation event trasmits yield message and also calls the handler

      expect(session).to receive(:emit).with(call_event.listen_event_name, Wamp::Message::Result).and_call_original
      session.on_message(result_message)
    end

    context "unregister a registered procedure" do
      let(:unregister_message) { Wamp::Message::Unregister.new(request_id + 1, registered_message.registration_id) }
      let(:unregister_event) { Wamp::Manager::Event::Unregister.new(unregister_message, session) }

      let(:unregistered_message) { Wamp::Message::Unregistered.new(request_id + 1) }
      let(:unregistered_event) { Wamp::Manager::Event::Unregistered.new(unregistered_message, session) }

      it "succeed" do
        expect(connection).to receive(:transmit).with(register_message.payload)
        handler = lambda do |m, n|
          m + n
        end
        session.register(register_message.procedure, handler, {})

        expect(session).to receive(:emit)
          .with(register_event.listen_event_name, Wamp::Message::Registered).and_call_original
        session.on_message(registered_message) # router sends this message on successful registration

        expect(connection).to receive(:transmit).with(unregister_message.payload)
        session.unregister(unregister_message.registration_id) do |unregistered|
          expect(unregistered).to eq unregistered_message
        end

        expect(session).to receive(:emit)
          .with(unregister_event.listen_event_name, Wamp::Message::Unregistered).and_call_original
        session.on_message(unregistered_message)
      end
    end
  end

  context "failure" do
    context "already registered" do
      let(:error_message) do
        Wamp::Message::Error.new(Wamp::Message::Type::REGISTER, request_id + 1, {},
                                 "wamp.error.procedure_already_exists")
      end
      let(:error_event) { Wamp::Manager::Event::Error.new(error_message, session) }

      it "returns error" do
        expect(connection).to receive(:transmit).with(register_message.payload)
        handler = lambda do |m, n|
          m + n
        end
        session.register(register_message.procedure, handler, {})

        expect(session).to receive(:emit).with(register_event.listen_event_name,
                                               Wamp::Message::Registered).and_call_original
        session.on_message(registered_message) # router sends this message on successful registration

        # trying to register same procedure second time
        register_message.instance_eval { @request_id = 2 }
        expect(connection).to receive(:transmit).with(register_message.payload)
        session.register(register_message.procedure, handler, {})

        expect(session).to receive(:emit).with(error_event.listen_event_name, nil, Wamp::Message::Error)
        expect { session.on_message(error_message) }.to raise_error(RuntimeError)
      end
    end

    context "called unregistered procedure" do
      let(:error_message) do
        Wamp::Message::Error.new(Wamp::Message::Type::CALL, request_id, {}, "wamp.error.no_such_procedure")
      end
      let(:error_event) { Wamp::Manager::Event::Error.new(error_message, session) }

      it "returns error" do
        call_message.instance_eval { @request_id = 1 }
        expect(connection).to receive(:transmit).with(call_message.payload)
        session.call(call_message.procedure, {}, *call_message.args) do |_result, error|
          expect(error.error).to eq(error_message.error)
        end

        expect(session).to receive(:emit).with(call_event.listen_event_name, nil,
                                               Wamp::Message::Error).and_call_original
        expect { session.on_message(error_message) }.to raise_error(RuntimeError)
      end
    end
  end
end
