require_relative "../lib/laa_crime_forms_common/payment_basis"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::PaymentBasis do
  describe ".valid_basis?" do
    it "returns true for all known basis values" do
      described_class::ALL.each do |value|
        expect(described_class.valid_basis?(value)).to be(true)
      end
    end

    it "returns true for symbol values" do
      expect(described_class.valid_basis?(:digital_claim)).to be(true)
    end

    it "returns false for unknown values" do
      expect(described_class.valid_basis?("unknown")).to be(false)
    end
  end

  describe ".calculation_method_for" do
    it "maps existing payment records to calculated difference" do
      expect(described_class.calculation_method_for("existing_payment_record"))
        .to eq("calculated_difference")
    end

    it "maps direct-entry basis values to entered to be paid" do
      expect(described_class.calculation_method_for("digital_claim"))
        .to eq("entered_to_be_paid")
      expect(described_class.calculation_method_for("linked_no_original_payment"))
        .to eq("entered_to_be_paid")
      expect(described_class.calculation_method_for("new_unlinked_record"))
        .to eq("entered_to_be_paid")
      expect(described_class.calculation_method_for("standard_manual_entry"))
        .to eq("entered_to_be_paid")
    end

    it "returns nil for unknown basis values" do
      expect(described_class.calculation_method_for("unknown")).to be_nil
    end
  end
end
