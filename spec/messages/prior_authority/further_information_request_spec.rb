require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/messages/prior_authority/further_information_request"

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::FurtherInformationRequest do
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
          "cost_type" => "per_item",
          "items" => 5,
          "cost_per_item" => 3,
          "travel_time" => 30,
          "travel_cost_per_hour" => "21.7",
        },
      ],
      "resubmission_deadline" => "2021-3-17 14:21:23.00",
      "further_information_explanation" => fi_explanation,
      "incorrect_information_explanation" => correction_explanation,
    }
  end

  let(:fi_explanation) { "Hooey" }
  let(:correction_explanation) { "Booey" }

  before do
    I18n.load_path += Dir[File.join(__dir__, "../../../lib/locales", "**/*.yml")]
  end

  it "has a hard-coded template" do
    expect(subject.template).to eq "c8abf9ee-5cfe-44ab-9253-72111b7a35ba"
  end

  it "renders its contents" do
    expect(subject.contents).to include(
      laa_case_reference: "ABC",
      ufn: "DEF",
      defendant_name: "Joe Bloggs",
      application_total: "£163.55",
      date_to_respond_by: "17 March 2021",
      caseworker_information_requested: "## Further information request\n\nHooey\n\n## Amendment request\n\nBooey",
    )
  end

  context "when missing an explanation" do
    let(:fi_explanation) { "" }
    let(:correction_explanation) { "" }

    it "renders its contents" do
      expect(subject.contents).to include(
        caseworker_information_requested: "",
      )
    end
  end
end
