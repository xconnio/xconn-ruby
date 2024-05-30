# frozen_string_literal: true

RSpec.describe Wamp::MessageHandler::Api do
  let(:session_id) { 12_345 }
  let(:request_id) { 1 }
  let(:connection) { Wamp::Connection::WebSocketConnection.new }

  def received_message(message)
    connection.on_message(connection.joiner.serializer.serialize(message))
  end

  let(:welcome) { Wampproto::Message::Welcome.new(session_id, {}) }
  let(:received_welcome) { received_message(welcome) }

  before do
    allow(Wamp::Connection::WebsocketClient).to receive(:new)
      .and_return(instance_double(Wamp::Connection::WebsocketClient))
    allow(connection.websocket).to receive(:transmit)
    connection.joiner.send_hello
  end

  describe "#subscribe" do
    let(:topic) { "com.hello.subscribe" }
    let(:subscription_id) { 345 }
    let(:publication_id) { 999 }
    let(:subscribed) { Wampproto::Message::Subscribed.new(request_id, subscription_id) }
    let(:received_subscribed) { received_message(subscribed) }

    let(:unsubscribed) { Wampproto::Message::Unsubscribed.new(request_id + 1) }
    let(:received_unsubscribed) { received_message(unsubscribed) }

    let(:event) { Wampproto::Message::Event.new(subscription_id, publication_id, {}, 1, 2) }
    let(:received_event) { received_message(event) }

    let(:published) { Wampproto::Message::Published.new(request_id, publication_id) }
    let(:received_published) { received_message(published) }

    it "subscribes and unsubscribes" do
      connection.on_join do |api|
        handler = proc { |msg| msg }
        api.subscribe(topic, handler)
        received_subscribed
        expect(connection.store).to include("subscription_#{subscription_id}")

        api.unsubscribe(topic)
        received_unsubscribed
        expect(connection.store).not_to include("subscription_#{subscription_id}")
      end

      expect(connection.api).to receive(:subscribe).and_call_original
      received_welcome
    end

    it "subscribes and receives event" do
      connection.on_join do |api|
        handler = proc { |msg| msg }
        api.subscribe(topic, handler)
        received_subscribed
        expect(connection.store).to include("subscription_#{subscription_id}")

        expect(handler).to receive(:call).and_return(event)
        received_event
      end

      expect(connection.api).to receive(:subscribe).and_call_original
      received_welcome
    end

    it "publishes an event" do
      connection.on_join do |api|
        api.publish(topic, { acknowledge: true }, 1, 2) do
          expect(connection.store).not_to include("request_#{request_id}")
        end
        expect(connection.store).to include("request_#{request_id}")
      end
      received_welcome
      expect(connection.store).to include("request_#{request_id}")
    end
  end

  describe "#register" do
    let(:procedure) { "com.hello.register" }
    let(:registration_id) { 8877 }
    let(:registered) { Wampproto::Message::Registered.new(request_id, registration_id) }
    let(:received_registered) { received_message(registered) }

    let(:unregistered) { Wampproto::Message::Unregistered.new(request_id + 1) }
    let(:received_unregistered) { received_message(unregistered) }

    let(:invocation) { Wampproto::Message::Invocation.new(request_id + 1, registration_id, {}, 1) }
    let(:received_invocation) { received_message(invocation) }

    it "registers and unregisters a procedure" do
      connection.on_join do |api|
        handler = proc { |msg| msg }
        api.register(procedure, handler) do |response|
          expect(response).to be_an_instance_of(Wamp::Type::Registration)
        end
        received_registered
        expect(connection.store).to include("registration_#{registration_id}")

        api.unregister(procedure) do |response|
          expect(response).to be_an_instance_of(Wamp::Type::Success)
        end
        received_unregistered
        expect(connection.store).not_to include("registration_#{registration_id}")
      end
      expect(connection.api).to receive(:register).and_call_original

      received_welcome
    end

    it "registers and receives invocation" do
      connection.on_join do |api|
        handler = proc { |msg| expect(msg).to be_an_instance_of(Wamp::Type::Invocation) }

        api.register(procedure, handler) do |response|
          expect(response).to be_an_instance_of(Wamp::Type::Registration)
        end
        received_registered
        expect(connection.store).to include("registration_#{registration_id}")

        expect(handler).to receive(:call)
        received_invocation
      end
      expect(connection.api).to receive(:register).and_call_original

      received_welcome
    end
  end

  describe "#call" do
    let(:procedure) { "com.hello.register" }
    # let(:call) { Wampproto::Message::Call.new(request_id, {}, procedure) }
    # let(:received_call) { received_message(call) }

    let(:result) { Wampproto::Message::Result.new(request_id, {}, procedure, 4) }
    let(:received_result) { received_message(result) }

    it "calls the procedure and receives the result" do
      connection.on_join do |api|
        counter = 1
        api.call(procedure, {}, 2) do |response|
          counter += 1
          expect(response).to be_an_instance_of(Wamp::Type::Result)
        end

        expect(connection.store).to include("request_#{request_id}")
        expect { received_result }.to change { counter }.by(1)

        expect(connection.store).not_to include("request_#{request_id}")
      end

      expect(connection.api).to receive(:call).and_call_original
      received_welcome
    end
  end
end
