require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/messages/prior_authority/part_granted"

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::PartGranted do
  subject { described_class.new(data) }

  let(:data) do
    {
      "laa_reference" => "ABC",
      "ufn" => "DEF",
      "solicitor" => {
        "contact_email" => "foo@bar.com",
      },
      "defendant" => {
        "first_name" => "Joe",
        "last_name" => "Bloggs",
      },
      "additional_costs" => [
        {
          "unit_type" => "per_item",
          "items" => 10,
          "items_original" => 11,
          "cost_per_item" => "12.3",
          "cost_per_item_original" => "12.4",
        },
        {
          "unit_type" => "per_hour",
          "period" => 60,
          "period_original" => 65,
          "cost_per_hour" => "14.7",
          "cost_per_hour_original" => "14.8",
        },
      ],
      "quotes" => [
        {
          "primary" => true,
          "cost_multiplier" => 1,
          "cost_type" => "per_hour",
          "period" => 65,
          "period_original" => 70,
          "cost_per_hour" => "33.2",
          "cost_per_hour_original" => "33.4",
          "travel_time" => 30,
          "travel_time_original" => 35,
          "travel_cost_per_hour" => "21.7",
          "travel_cost_per_hour_original" => "21.8",
          "contact_first_name" => "Jane",
          "contact_last_name" => "Bloggs",
          "organisation" => "Acme",
          "town" => "London",
          "postcode" => "IP1 1AA",
        },
      ],
      "service_type" => "custom",
      "custom_service_name" => "Blah",
      "assessment_comment" => "Bling",
    }
  end

  it "has a hard-coded template" do
    expect(subject.template).to eq "97c0245f-9fec-4ec1-98cc-c9d392a81254"
  end

  it "renders its contents" do
    expect(subject.contents).to include(
      laa_case_reference: "ABC",
      ufn: "DEF",
      defendant_name: "Joe Bloggs",
      service_required: "Blah",
      service_provider_details: "Jane Bloggs, Acme, London, IP1 1AA",
      application_total: "£204.12",
      part_grant_total: "£184.52",
      caseworker_decision_explanation: "Bling",
    )
  end
end
