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

  describe "#calculate_work_item" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }
    let(:work_item) do
      {
        claimed_time_spent_in_minutes: 50,
        claimed_work_type: "advocacy",
        claimed_uplift_percentage: 20,
        assessed_time_spent_in_minutes: 25,
        assessed_work_type: "travel",
        assessed_uplift_percentage: 85,
      }
    end

    it "returns calculated values" do
      expect(described_class.calculate_work_item(claim, work_item)).to eq({
        claimed_total_without_uplift: Rational(3271, 60),
        claimed_total_with_uplift: Rational(3271, 50),
        assessed_total_without_uplift: Rational(23, 2),
        assessed_total_with_uplift: Rational(851, 40),
      })
    end

    it "errors on invalid data" do
      work_item = {
        claimed_time_spent_in_minutes: 50,
        claimed_work_type: "advocacy",
        claimed_uplift_percentage: nil,
        assessed_time_spent_in_minutes: 25.2,
        assessed_work_type: "travel",
        assessed_uplift_percentage: 85,
      }

      expect { described_class.calculate_work_item(claim, work_item) }.to raise_error(
        "'claimed_uplift_percentage' in Hash is nil, but must not be",
      )
    end
  end
end
