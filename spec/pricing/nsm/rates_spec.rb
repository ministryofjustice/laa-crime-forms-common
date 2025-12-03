require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/pricing/nsm/rates"
require_relative "../../../lib/laa_crime_forms_common/pricing/nsm/wrappers/claim"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm::Rates do
  let(:claim) do
    { claim_type:, cntp_date:, rep_order_date: }
  end
  let(:cntp_date) { nil }
  let(:rep_order_date) { nil }

  describe ".call" do
    subject { described_class.call(LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Claim.new(claim)) }

    context "when the claim is BOI" do
      let(:claim_type) { "breach_of_injunction" }

      context "when CNTP date is not set" do
        it "raises an error" do
          expect { subject }.to raise_error "No date set for claim"
        end
      end

      context "when CNTP date is pre the 2022 change" do
        let(:cntp_date) { "2022-09-29" }

        it "returns old pricing data" do
          expect(subject.work_items[:preparation]).to eq 45.35
        end
      end

      context "when CNTP date is post the 2022 change" do
        let(:cntp_date) { "2022-09-30" }

        it "returns new pricing data" do
          expect(subject.work_items[:preparation]).to eq 52.15
        end

        it "has appropriate fields" do
          rates = subject
          expect([rates.work_items, rates.letters_and_calls, rates.disbursements, rates.vat]).to all be_truthy
        end
      end

      context "when CNTP date is post the 2025 10% uplift" do
        let(:cntp_date) { "2025-12-02" }

        it "returns new pricing data" do
          expect(subject.work_items[:preparation]).to eq 57.37
        end

        it "has appropriate fields" do
          rates = subject
          expect([rates.work_items, rates.letters_and_calls, rates.disbursements, rates.vat]).to all be_truthy
        end
      end
    end

    context "when the claim is NSM" do
      let(:claim_type) { "non_standard_magistrate" }
      let(:rep_order_date) { "2022-09-30" }

      it "returns pricing data based on rep order date" do
        expect(subject.work_items[:preparation]).to eq 52.15
      end
    end

    context "when the claim is of unknown type" do
      let(:claim_type) { "unknown" }

      it "raises an error" do
        expect { subject }.to raise_error "Unrecognised claim type 'unknown'"
      end
    end
  end
end
