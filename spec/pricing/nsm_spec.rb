require "bigdecimal"
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
        claimed_subtotal_without_uplift: Rational(3271, 60),
        claimed_total: Rational(3271, 50),
        assessed_subtotal_without_uplift: Rational(23, 2),
        assessed_total: Rational(851, 40),
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

  describe "#calculate_disbursement" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }

    context 'when disbursement is "other" type' do
      let(:disbursement) do
        {
          disbursement_type: "other",
          claimed_cost: BigDecimal("123.45"),
          assessed_cost: BigDecimal("85.67"),
          claimed_miles: nil,
          assessed_miles: nil,
        }
      end

      it "returns provided values" do
        expect(described_class.calculate_disbursement(claim, disbursement)).to eq({
          claimed_total: BigDecimal("123.45"),
          assessed_total: BigDecimal("85.67"),
        })
      end
    end

    context "when disbursement is miles-based type" do
      let(:disbursement) do
        {
          disbursement_type: "car",
          claimed_cost: nil,
          assessed_cost: nil,
          claimed_miles: BigDecimal("12.3"),
          assessed_miles: BigDecimal("12.2"),
        }
      end

      it "returns calculated values" do
        expect(described_class.calculate_disbursement(claim, disbursement)).to eq({
          claimed_total: BigDecimal("5.535"),
          assessed_total: BigDecimal("5.49"),
        })
      end
    end
  end

  describe "#calculate_letter_or_call" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }
    let(:letter_or_call) { { type: :letter, claimed_items: 10, assessed_items: 8 } }

    it "applies rates correctly" do
      expect(described_class.calculate_letter_or_call(claim, letter_or_call)).to eq({
        claimed_total: BigDecimal("40.9"),
        assessed_total: BigDecimal("32.72"),
      })
    end
  end
end
