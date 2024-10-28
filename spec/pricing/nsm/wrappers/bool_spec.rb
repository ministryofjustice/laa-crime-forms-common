require "spec_helper"
require_relative "../../../../lib/laa_crime_forms_common/pricing/nsm/wrappers/bool"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Bool do
  describe ".call" do
    subject { described_class.call(input) }

    context "when passed true" do
      let(:input) { true }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when passed false" do
      let(:input) { false }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "when passed something lse" do
      let(:input) { [] }

      it "raises an error" do
        expect { subject }.to raise_error "Cannot cast Array to true or false"
      end
    end
  end
end
