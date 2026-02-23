require_relative "../lib/laa_crime_forms_common/court"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::Court do
  describe ".all" do
    subject { described_class.all }

    it "returns required courts as expected" do
      digest_of_expected_court_names = "88aff34c81d39f306905cc7cbef807fa"
      digest_of_expected_court_ids = "25ed0135c77f910c3ac9493c732ec806"
      digest_of_expected_short_court_names = "518956c5e16fbede58bd3beba845a924"

      expect(Digest::MD5.hexdigest(subject.map(&:name).join)).to eq digest_of_expected_court_names
      expect(Digest::MD5.hexdigest(subject.map(&:id).join)).to eq digest_of_expected_court_ids
      expect(Digest::MD5.hexdigest(subject.map(&:short_name).join)).to eq digest_of_expected_short_court_names
    end
  end

  describe "#==" do
    subject { described_class.new(id: 1, short_name: "check_against", name: "1 - check_against") }

    context "when other object is the same value" do
      it { expect(subject).to eq(described_class.new(id: 1, short_name: "check_against", name: "1 - check_against")) }
    end

    context "when other object has a different value" do
      it { expect(subject).not_to eq(described_class.new(id: 2, short_name: "different", name: "2 - different")) }
    end
  end
end
