require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/messages/prior_authority/granted"

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::Granted do
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
          "cost_per_item" => "12.3",
        },
        {
          "unit_type" => "per_hour",
          "period" => 60,
          "cost_per_hour" => "14.7",
        },
      ],
      "quotes" => [
        {
          "primary" => true,
          "cost_multiplier" => 1,
          "cost_type" => "per_hour",
          "period" => 65,
          "cost_per_hour" => "33.2",
          "travel_time" => 30,
          "travel_cost_per_hour" => "21.7",
          "contact_first_name" => "Jane",
          "contact_last_name" => "Bloggs",
          "organisation" => "Acme",
          "town" => "London",
          "postcode" => "IP1 1AA",
        },
      ],
      "service_type" => "pathologist_report",
    }
  end

  before do
    I18n.load_path += Dir[File.join(__dir__, "../../../lib/locales", "**/*.yml")]
  end

  it "has a hard-coded template" do
    expect(subject.template).to eq "d4f3da60-4da5-423e-bc93-d9235ff01a7b"
  end

  it "renders its contents" do
    expect(subject.contents).to include(
      laa_case_reference: "ABC",
      ufn: "DEF",
      defendant_name: "Joe Bloggs",
      service_required: "Pathologist report",
      service_provider_details: "Jane Bloggs, Acme, London, IP1 1AA",
      application_total: "£184.52",
    )
  end
end
