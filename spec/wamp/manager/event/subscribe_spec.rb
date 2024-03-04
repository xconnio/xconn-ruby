# frozen_string_literal: true

RSpec.describe Wamp::Manager::Event::Subscribe do
  let(:session_id) { 1_234_567 }
  let(:request_id) { 1 }
  let(:details) { {} }
  let(:subscribe_message) { Wamp::Message::Subscribe.new(request_id, {}, "com.rspec.sum") }
  let(:subscribe_event) { Wamp::Manager::Event::Subscribe.new(subscribe_message, session) }
  let(:subscription_id) { 100 }
  let(:next_request_id) { request_id + 1 }
  let(:publication_id) { 200 }

  let(:subscribed_message) { Wamp::Message::Subscribed.new(request_id, subscription_id) }
  let(:subscribed_event) { Wamp::Manager::Event::Subscribed.new(subscribed_message, session) }

  let(:publish_message) do
    Wamp::Message::Publish.new(next_request_id, {}, subscribe_message.topic, 2, 3)
  end
  let(:publish_event) { Wamp::Manager::Event::Publish.new(publish_message, session) }

  let(:event_message) do
    Wamp::Message::Event.new(subscription_id, publication_id, {}, *publish_message.args)
  end

  let(:unsubscribe_message) { Wamp::Message::Unsubscribe.new(next_request_id, subscribed_message.subscription_id) }
  let(:unsubscribed_message) { Wamp::Message::Unsubscribed.new(next_request_id) }

  let(:connection) { Wamp::Manager::Base.new }
  let(:session) { connection.session }

  context "success" do
    context "subscribe message sent" do
      it "gets subscribed" do
        expect(connection).to receive(:transmit).with(subscribe_message.payload)
        handler = lambda do |n, m|
          n + m
        end
        session.subscribe(subscribe_message.topic, handler, subscribe_message.options)

        connection.on_message(subscribed_message)

        expect(connection).to receive(:transmit).with(publish_message.payload)
        session.publish(subscribe_message.topic, {}, *publish_message.args)

        expect(handler).to receive(:call).with(*publish_message.args).and_call_original
        connection.on_message(event_message)
      end

      it "gets unsubscribed after subscribing" do
        expect(connection).to receive(:transmit).with(subscribe_message.payload)
        handler = lambda do |n, m|
          n + m
        end
        session.subscribe(subscribe_message.topic, handler, subscribe_message.options)

        connection.on_message(subscribed_message)

        expect(connection).to receive(:transmit).with(unsubscribe_message.payload)
        session.unsubscribe(unsubscribe_message.subscription_id)

        connection.on_message(unsubscribed_message)

        publish_message.instance_eval { @request_id = 3 }
        expect(connection).to receive(:transmit).with(publish_message.payload)
        session.publish(subscribe_message.topic, {}, *publish_message.args, **publish_message.kwargs)

        expect(handler).not_to receive(:call).with(*publish_message.args, **publish_message.kwargs)
        connection.on_message(event_message)
      end
    end
  end
end
