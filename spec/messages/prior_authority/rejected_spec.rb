require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/messages/prior_authority/rejected"

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::Rejected do
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
          "travel_time" => 0,
          "travel_cost_per_hour" => "0",
          "contact_first_name" => "Jane",
          "contact_last_name" => "Bloggs",
          "organisation" => "Acme",
          "town" => "London",
          "postcode" => "IP1 1AA",
        },
      ],
      "service_type" => "pathologist_report",
      "assessment_comment" => "Boo",
    }
  end

  before do
    I18n.load_path += Dir[File.join(__dir__, "../../../lib/locales", "**/*.yml")]
  end

  it "has a hard-coded template" do
    expect(subject.template).to eq "81e9222e-c6bd-4fba-91ff-d90d3d61af87"
  end

  it "renders its contents" do
    expect(subject.contents).to include(
      laa_case_reference: "ABC",
      ufn: "DEF",
      defendant_name: "Joe Bloggs",
      application_total: "£173.67",
      caseworker_decision_explanation: "Boo",
    )
  end
end
