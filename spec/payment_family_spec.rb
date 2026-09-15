require_relative "../lib/laa_crime_forms_common/payment_family"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::PaymentFamily do
  describe "find_claim_type_group" do
    it "returns the correct claim type group for a given request type" do
      expect(described_class.find_claim_type_group("breach_of_injunction")).to eq("NsmClaim")
      expect(described_class.find_claim_type_group("assigned_counsel")).to eq("AssignedCounselClaim")
    end

    it "returns nil for an unknown request type" do
      expect(described_class.find_claim_type_group("unknown")).to be_nil
    end
  end

  describe "get_claim_type_marker" do
    it "returns the correct claim type marker for a given request type" do
      expect(described_class.get_claim_type_marker("breach_of_injunction")).to eq("non_standard_magistrate")
      expect(described_class.get_claim_type_marker("assigned_counsel_amendment")).to eq("assigned_counsel")
    end

    it "raises an error for an unknown request type" do
      expect { described_class.get_claim_type_marker("unknown") }.to raise_error(StandardError, "request type 'unknown' is not recognized")
    end
  end
end
