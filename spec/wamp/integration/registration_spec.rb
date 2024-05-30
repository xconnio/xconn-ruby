# frozen_string_literal: true

RSpec.describe "registrations" do
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
  let(:procedure) { "com.hello.world" }
  before { router.add_realm(realm) }

  context "registers" do
    before { client.on_open }
    let(:client) { create_client_session(router) }
    it "to a procedure" do
      counter = 0
      handler = proc {}

      expect do
        client.api.register(procedure, handler) do |response|
          counter += 1
          expect(response).to be_an_instance_of(Wampproto::Message::Registered)
        end
      end.to change { counter }.by(1)
    end

    context "calls" do
      before { client2.on_open }
      before { client.api.register(procedure, proc {}) }
      let(:client2) { create_client_session(router) }

      it "to a registered procedure" do
        counter = 0

        expect do
          client2.api.call(procedure) do |response|
            counter += 1
            expect(response).to be_an_instance_of(Wampproto::Message::Result)
          end
        end.to change { counter }.by(1)
      end
    end

    context "unregisters" do
      before { client.api.register(procedure, proc {}) }

      it "a registered procedure" do
        counter = 0

        expect do
          client.api.unregister(procedure) do |response|
            counter += 1
            expect(response).to be_an_instance_of(Wampproto::Message::Unregistered)
          end
        end.to change { counter }.by(1)
      end
    end

    context "non existant procedure" do
      it "returns an error" do
        counter = 0

        expect do
          client.api.unregister(procedure) do |response|
            counter += 1
            expect(response).to be_an_instance_of(Wampproto::Message::Error)
          end
        end.to change { counter }.by(1)
      end
    end
  end
end
