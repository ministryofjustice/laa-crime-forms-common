require "spec_helper"
require_relative "../../../../lib/laa_crime_forms_common/risk/nsm/v1/high_risk_detector"

RSpec.describe LaaCrimeFormsCommon::Risk::Nsm::V1::HighRiskDetector do
  describe ".call" do
    subject(:assessment) { described_class.call(claim, is_high_value) }

    let(:claim) do
      {
        assigned_counsel:,
        unassigned_counsel:,
        agent_instructed:,
        reasons_for_claim:,
      }.transform_keys(&:to_s)
    end
    let(:assigned_counsel) { "no" }
    let(:unassigned_counsel) { "no" }
    let(:agent_instructed) { "no" }
    let(:reasons_for_claim) { %w[core_costs_exceed_higher_limit] }
    let(:is_high_value) { false }

    it "returns false when no clauses are triggered" do
      expect(assessment).to be_falsey
    end

    context "is high value" do
      let(:is_high_value) { true }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when there is an assigned counsel" do
      let(:assigned_counsel) { "yes" }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when there is an unassigned counsel" do
      let(:unassigned_counsel) { "yes" }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when there is an instructed agent" do
      let(:agent_instructed) { "yes" }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when enhanced rates are claimed" do
      let(:reasons_for_claim) { %w[enhanced_rates_claimed] }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when there is an extradition" do
      let(:reasons_for_claim) { %w[extradition] }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end

    context "when a rep order is withdrawn" do
      let(:reasons_for_claim) { %w[representation_order_withdrawn] }

      it "returns true" do
        expect(assessment).to be_truthy
      end
    end
  end
end
