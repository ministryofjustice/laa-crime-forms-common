require "spec_helper"
require_relative "../../../lib/laa_crime_forms_common/messages/prior_authority/base"

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::Base do
  subject { described_class.new(data) }

  let(:data) do
    {
      "solicitor" => {
        "contact_email" => "foo@bar.com",
      },
    }
  end

  it "raises without a template" do
    expect { subject.template }.to raise_error NotImplementedError
  end

  it "raises without contents" do
    expect { subject.contents }.to raise_error NotImplementedError
  end

  it "returns the recipient" do
    expect(subject.recipient).to eq "foo@bar.com"
  end
end
