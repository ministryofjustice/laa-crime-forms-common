require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/pricing/nsm/wrappers/base"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm::Wrappers do
  let(:wrapper) do
    Class.new(LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base) do
      wrap :attribute_with_default, String, default: "DEFAULT"
      wrap :attribute, String
    end
  end

  subject { wrapper.new(input) }

  describe ".wrap" do
    context "when initialized with a hash with string keys" do
      let(:input) { { "attribute" => "foo" } }

      it "wraps it correctly" do
        expect(subject.attribute).to eq "foo"
      end
    end

    context "when initialized with a hash with symbol keys" do
      let(:input) { { attribute: "foo" } }

      it "wraps it correctly" do
        expect(subject.attribute).to eq "foo"
      end
    end

    context "when initialized with a hash with missing keys" do
      let(:input) { {} }

      it "raises an error" do
        expect { subject.attribute }.to raise_error "Hash does not have 'attribute' attribute"
      end
    end

    context "when initialized with an object with unconvertable attributes" do
      let(:input) { { attribute: [] } }

      it "raises an error" do
        expect { subject.attribute }.to raise_error(/'attribute' in .* is of type Array but should be of type String/)
      end
    end

    context "when initialized with an object with a nil value but there is a default" do
      let(:input) { { attribute_with_default: nil } }

      it "uses the default" do
        expect(subject.attribute_with_default).to eq "DEFAULT"
      end
    end

    context "when initialized with an object with a nil value and there is no default" do
      let(:input) { { attribute: nil } }

      it "raises an error" do
        expect { subject.attribute }.to raise_error(/'attribute' in .* is nil, but must not be/)
      end
    end
  end
end
