require "spec_helper"
require_relative "../../lib/laa_crime_forms_common/pricing/nsm"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm do
  describe "#rates" do
    it "returns relevant rates for a valid claim" do
      claim = { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" }
      ret = described_class.rates(claim)
      expect(ret).to be_a(LaaCrimeFormsCommon::Pricing::Nsm::Rates)
    end

    it "raises on invalid data" do
      claim = { claim_type: "unknown" }
      expect { described_class.rates(claim) }.to raise_error "Unrecognised claim type 'unknown'"
    end
  end
end
