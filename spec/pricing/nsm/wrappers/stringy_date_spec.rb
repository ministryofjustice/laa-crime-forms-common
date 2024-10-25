require "spec_helper"
require_relative "../../../../lib/laa_crime_forms_common/pricing/nsm/wrappers/stringy_date"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::StringyDate do
  describe ".new" do
    context "when passed a string" do
      let(:input) { "2020-09-02" }

      it "parses the string correctly" do
        expect(described_class.new(input)).to eq Date.new(2020, 9, 2)
      end
    end

    context "when passed a date" do
      let(:input) { Date.new(2020, 9, 2) }

      it "instantiates a matching date" do
        expect(described_class.new(input)).to eq Date.new(2020, 9, 2)
      end
    end
  end
end
