# frozen_string_literal: true

RSpec.describe Wamp::Message::Welcome do
  describe ".parse" do
    let(:subject) { described_class.parse(wamp_message) }
    context "valid" do
      let(:wamp_message) { [2, 123, {}] }
      it { is_expected.to be_instance_of(described_class) }
    end

    context "invalid" do
      context "empty message" do
        let(:wamp_message) { [] }
        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context "wrong session_id type" do
        let(:wamp_message) { [1, "abc", {}] }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
