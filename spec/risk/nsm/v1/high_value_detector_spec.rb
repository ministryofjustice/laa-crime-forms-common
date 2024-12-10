require "spec_helper"
require_relative "../../../../lib/laa_crime_forms_common/risk/nsm/v1/high_value_detector"

RSpec.describe LaaCrimeFormsCommon::Risk::Nsm::V1::HighValueDetector do
  describe ".call" do
    subject(:assessment) { described_class.call(claim) }

    let(:claim) do
      {
        "work_items" => [],
        "letters_and_calls" => [],
        "disbursements" => [],
      }
    end

    let(:claimed_total_inc_vat) { 100 }
    let(:totals) do
      { cost_summary: { profit_costs: { claimed_total_inc_vat: } } }
    end

    before do
      allow(LaaCrimeFormsCommon::Pricing::Nsm).to receive(:totals).and_return(totals)
    end

    context "when total profit cost inc vat is less than 5000" do
      let(:claimed_total_inc_vat) { 4999 }

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "when total profit cost inc vat is more than 5000" do
      let(:claimed_total_inc_vat) { 5001 }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when total profit cost inc vat is exactly 5000" do
      let(:claimed_total_inc_vat) { 5000 }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when it is a non-BOI claim" do
      let(:claim) do
        {
          "claim_type" => "non_standard_magistrate",
          "rep_order_date" => "2024-1-1",
          "cntp_date" => nil,
          "include_youth_court_fee" => true,
          "youth_court" => "yes",
          "plea_category" => "category_2a",
          "firm_office" => { "vat_registered" => "yes" },
          "work_items" => [{ "time_spent" => 80, "work_type" => "travel", "uplift" => 50 }],
          "letters_and_calls" => [{ "count" => 80, "type" => "letters", "uplift" => 50 }],
          "disbursements" => [{ "disbursement_type" => "car", "miles" => "10.3", "total_cost_without_vat" => nil, "apply_vat" => "true" }],
        }
      end

      it "passes appropriate details to the calculator" do
        subject
        expect(LaaCrimeFormsCommon::Pricing::Nsm).to have_received(:totals).with(
          claim_type: "non_standard_magistrate",
          rep_order_date: Date.new(2024, 1, 1),
          cntp_date: nil,
          claimed_youth_court_fee_included: true,
          assessed_youth_court_fee_included: false,
          youth_court: true,
          plea_category: "category_2a",
          vat_registered: true,
          work_items: [
            {
              claimed_time_spent_in_minutes: 80,
              claimed_work_type: "travel",
              claimed_uplift_percentage: 50,
              assessed_time_spent_in_minutes: 0,
              assessed_work_type: "travel",
              assessed_uplift_percentage: 0,
            },
          ],
          letters_and_calls: [
            {
              type: :letters,
              claimed_items: 80,
              claimed_uplift_percentage: 50,
              assessed_items: 0,
              assessed_uplift_percentage: 0,
            },
          ],
          disbursements: [
            {
              disbursement_type: "car",
              claimed_cost: nil,
              claimed_miles: BigDecimal("10.3"),
              claimed_apply_vat: true,
              assessed_cost: 0,
              assessed_miles: BigDecimal(0),
              assessed_apply_vat: false,
            },
          ],
        )
      end
    end

    context "when it is a BOI claim" do
      let(:claim) do
        {
          "claim_type" => "breach_of_injunction",
          "rep_order_date" => nil,
          "cntp_date" => "2024-1-1",
          "include_youth_court_fee" => nil,
          "youth_court" => "no",
          "plea_category" => "category_1a",
          "firm_office" => { "vat_registered" => "no" },
          "work_items" => [{ "time_spent" => 80, "work_type" => "travel", "uplift" => nil }],
          "letters_and_calls" => [{ "count" => 80, "type" => "letters", "uplift" => nil }],
          "disbursements" => [{ "disbursement_type" => "other", "miles" => nil, "total_cost_without_vat" => "100.2", "apply_vat" => "false" }],
        }
      end

      it "passes appropriate details to the calculator" do
        subject
        expect(LaaCrimeFormsCommon::Pricing::Nsm).to have_received(:totals).with(
          claim_type: "breach_of_injunction",
          rep_order_date: nil,
          cntp_date: Date.new(2024, 1, 1),
          claimed_youth_court_fee_included: false,
          assessed_youth_court_fee_included: false,
          youth_court: false,
          plea_category: "category_1a",
          vat_registered: false,
          work_items: [
            {
              claimed_time_spent_in_minutes: 80,
              claimed_work_type: "travel",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 0,
              assessed_work_type: "travel",
              assessed_uplift_percentage: 0,
            },
          ],
          letters_and_calls: [
            {
              type: :letters,
              claimed_items: 80,
              claimed_uplift_percentage: 0,
              assessed_items: 0,
              assessed_uplift_percentage: 0,
            },
          ],
          disbursements: [
            {
              disbursement_type: "other",
              claimed_cost: BigDecimal("100.2"),
              claimed_miles: nil,
              claimed_apply_vat: false,
              assessed_cost: 0,
              assessed_miles: BigDecimal(0),
              assessed_apply_vat: false,
            },
          ],
        )
      end
    end
  end
end
