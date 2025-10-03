require_relative "../lib/laa_crime_forms_common/outcome_code"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::OutcomeCode do
  subject { described_class.new("CP01") }

  describe "#all" do
    it "returns a know number of outcomes" do
      expect(described_class.all.count).to eq(22)
    end
  end

  it { expect(subject.id).to eq("CP01") }
  it { expect(subject.description).to eq("Arrest warrant issued/adjourned indefinitely") }
  it { expect(subject.name).to eq("CP01 - Arrest warrant issued/adjourned indefinitely") }
end
