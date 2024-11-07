require "spec_helper"
require_relative "../../../../lib/laa_crime_forms_common/pricing/nsm/wrappers/date_or_date_string"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::DateOrDateString do
  describe ".call" do
    subject { described_class.call(input) }

    context "when passed a string" do
      let(:input) { "2020-09-02" }

      it "parses the string correctly" do
        expect(subject).to eq Date.new(2020, 9, 2)
      end
    end

    context "when passed a date" do
      let(:input) { Date.new(2020, 9, 2) }

      it "instantiates a matching date" do
        expect(subject).to eq Date.new(2020, 9, 2)
      end
    end

    context "when passed something lse" do
      let(:input) { [] }

      it "raises an error" do
        expect { subject }.to raise_error "Cannot cast Array to Date"
      end
    end
  end
end
