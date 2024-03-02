# frozen_string_literal: true

RSpec.describe Wamp::Manager::Event::Welcome do
  let(:session_id) { 1_234_567 }
  let(:details) { {} }
  let(:welcome_message) { Wamp::Message::Welcome.new(session_id, details) }
  let(:welcome_event) { Wamp::Manager::Event::Welcome.new(welcome_message, connection.session) }

  context "success" do
    context "hello message sent" do
      let(:connection) { Wamp::Manager::Base.new }
      let(:hello) { Wamp::Message::Hello.new("reaml1", {}) }
      let(:hello_event) { Wamp::Manager::Event::Hello.new(hello, connection.session) }
      it "receives welcome message" do
        expect(connection).to receive(:transmit).with(hello.payload)
        hello_event.add_event_listener # transmits hello message

        connection.on(welcome_event.emit_event_name) do |session|
          expect(session).to eq(connection.session)
        end

        connection.on_message(welcome_message)
      end
    end
  end

  context "failure" do
    # [3, {}, "wamp.error.no_such_realm"]
    let(:abort_message) { Wamp::Message::Abort.new({}, "wamp.error.no_such_realm") }
    let(:abort_event) { Wamp::Manager::Event::Abort.new(abort_message, connection.session) }

    context "hello message sent" do
      let(:connection) { Wamp::Manager::Base.new }
      let(:hello) { Wamp::Message::Hello.new("INVALID_REALM", {}) }
      let(:hello_event) { Wamp::Manager::Event::Hello.new(hello, connection.session) }
      it "receives abort" do
        expect(connection).to receive(:transmit).with(hello.payload)
        hello_event.add_event_listener # transmits hello message

        expect(connection).to receive(:close).with(1000, abort_event.reason)
        connection.on(abort_event.emit_event_name) do |message|
          expect(message).to be_instance_of(Wamp::Message::Abort)
        end

        connection.on_message(abort_message)
      end
    end
  end
end
