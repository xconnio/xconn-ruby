# frozen_string_literal: true

RSpec.describe "subscriptions" do
  def create_client_session(router)
    session = Wamp::Connection::Session.new

    server_session = Wamp::Router::Client.new
    server_session.router = router
    server_session.connection = session

    session.stream = server_session
    session
  end

  let(:realm) { "realm1" }
  let(:router) { Wamp::Router::Base.new }
  let(:topic) { "com.hello.world" }
  before { router.add_realm(realm) }

  context "subscribes" do
    before { client.on_open }
    let(:client) { create_client_session(router) }
    it "to a topic" do
      subscription_counter = 0
      handler = proc {}

      expect do
        client.api.subscribe(topic, handler) do |response|
          subscription_counter += 1
          expect(response).to be_an_instance_of(Wampproto::Message::Subscribed)
        end
      end.to change { subscription_counter }.by(1)
    end

    context "publishes" do
      before { client2.on_open }
      let(:client2) { create_client_session(router) }

      before do
        handler = proc { 100 }
        client.api.subscribe(topic, handler)
        expect(handler).to receive(:call).and_call_original
      end

      it "to a topic" do
        counter = 0
        expect do
          client2.api.publish(topic) do |response|
            counter += 1
            expect(response).to be_instance_of(Wampproto::Message::Published)
          end
        end.to change { counter }.by(1)
      end
    end

    context "unsubscribes" do
      before { client.api.subscribe(topic, proc {}) }

      it "from a topic" do
        counter = 0
        expect do
          client.api.unsubscribe(topic) do |response|
            counter += 1
            expect(response).to be_an_instance_of(Wampproto::Message::Unsubscribed)
          end
        end.to change { counter }.by(1)
      end

      context "when subscription is missing" do
        it "returns error" do
          counter = 0
          expect do
            client.api.unsubscribe(129_876) do |response|
              counter += 1
              expect(response).to be_an_instance_of(Wampproto::Message::Error)
            end
          end.to change { counter }.by(1)
        end
      end
    end
  end
end
