require_relative "../lib/laa_crime_forms_common/matter_type"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::MatterType do
  subject { described_class.new("1") }

  describe "#all" do
    it "returns a know number of outcomes" do
      expect(described_class.all.count).to eq(16)
    end
  end

  it { expect(subject.id).to eq("1") }
  it { expect(subject.description).to eq("Offences against the person") }
  it { expect(subject.name).to eq("1 - Offences against the person") }
end
