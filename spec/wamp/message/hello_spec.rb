# frozen_string_literal: true

RSpec.describe Wamp::Message::Hello do
  describe "#initialize" do
    let(:subject) { described_class.new(*args) }
    context "valid arguments" do
      let(:args) { ["realm1"] }
      it "should create a hello message instance" do
        expect { subject }.not_to raise_error
        expect(subject.payload).to include(1)
        expect(subject.payload).to include("realm1")
      end
    end

    context "invalid" do
      let(:args) { [1] }
      context "realm" do
        it "should raise validation exception" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "details" do
        let(:args) { ["realm1", nil] }
        it "should raise validation exception" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
