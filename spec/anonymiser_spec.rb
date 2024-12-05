require_relative "../lib/laa_crime_forms_common/anonymiser"
require "spec_helper"
require "json-schema"

RSpec.describe LaaCrimeFormsCommon::Anonymiser do
  describe ".anonymise" do
    let(:service_type) { :prior_authority }
    let(:version) { 1 }
    let(:payload) do
      {
        "ufn" => "121212/001",
        "plea" => nil,
        "quotes" => [
          {
            "id" => "d94d6932-c4ec-4854-a5c6-f2e9a393e3b3",
            "town" => "asd",
            "items" => 1200,
            "period" => nil,
            "primary" => true,
            "document" => {
              "file_name" => "file.png",
              "file_path" => "123123123-cdecdeced-123123123",
              "file_size" => 232_687,
              "file_type" => "image/png",
              "document_type" => "quote_document",
            },
            "postcode" => "IP1 1AA",
            "organisation" => "Joe Schmo Ltd",
            "cost_item_type" => "thousand_words",
            "cost_multiplier" => "0.001",
            "ordered_by_court" => nil,
            "contact_last_name" => "Jim",
            "contact_first_name" => nil,
          },
        ],
        "status" => "granted",
        "provider" => {
          "email" => "provider@example.com",
          "description" => nil,
        },
        "defendant" => {
          "maat" => nil,
          "last_name" => "asd",
          "first_name" => "asd",
          "date_of_birth" => "2012-12-12",
        },
        "prison_id" => nil,
        "solicitor" => {
          "contact_email" => "asd@asd.asd",
          "reference_number" => nil,
          "contact_last_name" => "asd",
          "contact_first_name" => "asd",
        },
        "court_type" => nil,
        "created_at" => "2024-08-12T08:35:23.769Z",
        "prison_law" => true,
        "reason_why" => "asdasd",
        "updated_at" => "2024-11-18T10:35:41.413Z",
        "firm_office" => {
          "name" => "asd",
          "town" => nil,
          "postcode" => nil,
          "account_number" => "1A123B",
        },
        "no_alternative_quote_reason" => "asdas",
        "pending_granted_explanation" => "GRANTING",
        "pending_rejected_explanation" => "",
        "pending_part_grant_explanation" => "",
        "psychiatric_liaison_reason_not" => nil,
        "undocumented_field" => "FOO",
      }
    end

    let(:anonymised) do
      {
        "ufn" => "121212/001",
        "plea" => nil,
        "quotes" => [
          {
            "id" => "d94d6932-c4ec-4854-a5c6-f2e9a393e3b3",
            "town" => "asd",
            "items" => 1200,
            "period" => nil,
            "primary" => true,
            "document" => {
              "file_name" => "ANONYMISED",
              "file_path" => "123123123-cdecdeced-123123123",
              "file_size" => 232_687,
              "file_type" => "image/png",
              "document_type" => "quote_document",
            },
            "postcode" => "IP1 1AA",
            "organisation" => "Joe Schmo Ltd",
            "cost_item_type" => "thousand_words",
            "cost_multiplier" => "0.001",
            "ordered_by_court" => nil,
            "contact_last_name" => "ANONYMISED",
            "contact_first_name" => nil,
          },
        ],
        "status" => "granted",
        "provider" => {
          "email" => "ANONYMISED",
          "description" => nil,
        },
        "defendant" => {
          "maat" => nil,
          "last_name" => "ANONYMISED",
          "first_name" => "ANONYMISED",
          "date_of_birth" => "ANONYMISED",
        },
        "prison_id" => nil,
        "solicitor" => {
          "contact_email" => "ANONYMISED",
          "reference_number" => nil,
          "contact_last_name" => "ANONYMISED",
          "contact_first_name" => "ANONYMISED",
        },
        "court_type" => nil,
        "created_at" => "2024-08-12T08:35:23.769Z",
        "prison_law" => true,
        "reason_why" => "ANONYMISED",
        "updated_at" => "2024-11-18T10:35:41.413Z",
        "firm_office" => {
          "name" => "asd",
          "town" => nil,
          "postcode" => nil,
          "account_number" => "1A123B",
        },
        "no_alternative_quote_reason" => "asdas",
        "pending_granted_explanation" => "GRANTING",
        "pending_rejected_explanation" => "",
        "pending_part_grant_explanation" => "",
        "psychiatric_liaison_reason_not" => nil,
        "undocumented_field" => "FOO",
      }
    end

    subject { described_class.anonymise(service_type, payload, version:) }

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
      expect(subject).to eq anonymised
    end
  end
end
