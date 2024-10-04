require_relative "../lib/laa_crime_forms_common/validator"
require "spec_helper"
require "json-schema"

RSpec.describe LaaCrimeFormsCommon::Validator do
  describe ".validate" do
    let(:service_type) { :prior_authority }
    let(:version) { 1 }
    let(:payload) { { foo: :bar } }

    subject { LaaCrimeFormsCommon::Validator.validate(service_type, payload, version:) }

    context "when service_type is unknown" do
      let(:service_type) { :eoul }

      it "raises an error" do
        expect { subject }.to raise_error "Unknown service type"
      end
    end

    context "when version is unknown" do
      let(:version) { 2 }

      it "raises an error" do
        expect { subject }.to raise_error "Unknown version"
      end
    end

    it "highlights validation issues" do
      expect(subject).to include a_string_including "did not contain a required property of 'additional_costs'"
    end
  end
end
