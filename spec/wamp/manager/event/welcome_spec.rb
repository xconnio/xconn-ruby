# frozen_string_literal: true

RSpec.describe Wamp::Manager::Event::Welcome do
  let(:session_id) { 1_234_567 }
  let(:details) { {} }
  let(:realm) { "realm1" }
  let(:welcome_message) { Wamp::Message::Welcome.new(session_id, details) }
  let(:welcome_event) { Wamp::Manager::Event::Welcome.new(welcome_message, connection.session) }

  context "success" do
    let(:connection) { Wamp::Manager::Base.new }
    let(:hello_event) { Wamp::Manager::Event::Hello.new(hello, connection.session) }
    context "hello message sent" do
      let(:hello) { Wamp::Message::Hello.new(realm, {}) }
      it "receives welcome message" do
        expect(connection).to receive(:transmit).with(hello.payload)
        hello_event.add_event_listener # transmits hello message

        connection.on(welcome_event.emit_event_name) do |session|
          expect(session).to eq(connection.session)
        end

        connection.on_message(welcome_message)
      end
    end

    context "hello message including cryptosign auth details sent" do
      let(:connection) { Wamp::Manager::Base.new(auth: cryptosign) }
      let(:hello) { Wamp::Message::Hello.new(realm, cryptosign.details) }
      JSON.load_file("./spec/cryptosign_spec_cases.json").each.with_index(1) do |test_case, index|
        context index do
          let(:private_key) { test_case["private_key"] }
          let(:challenge) { test_case["challenge"] }
          let(:signature) { test_case["signature"] }
          let(:channel_id) { test_case["channel_id"].to_s.empty? ? nil : test_case["channel_id"] }
          let(:authextra) { { "channel_binding" => channel_id ? "tls-unique" : nil } }
          let(:cryptosign) { Wamp::Auth::Cryptosign.new(private_key, { authid: "joe", authextra: authextra }) }
          let(:challenge_message) do
            Wamp::Message::Challenge.new("cryptosign",
                                         { "challenge" => challenge, "channel_id" => channel_id,
                                           "channel_binding" => "tls-unique" })
          end
          let(:challenge_event) { Wamp::Manager::Event::Challenge.new(challenge_message, connection.session) }
          let(:authenticate_message) { Wamp::Message::Authenticate.new(signature, {}) }
          it "receives welcome message" do
            expect(connection).to receive(:transmit).with(hello.payload)
            hello_event.add_event_listener

            expect(connection).to receive(:transmit).with(authenticate_message.payload).and_call_original
            expect(connection).to receive(:emit).with(challenge_event.emit_event_name,
                                                      Wamp::Message::Challenge).and_call_original
            connection.on_message(challenge_message)

            expect(connection).to receive(:emit).with(welcome_event.emit_event_name,
                                                      Wamp::Manager::Session).and_call_original
            connection.on_message(welcome_message)
          end
        end
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
