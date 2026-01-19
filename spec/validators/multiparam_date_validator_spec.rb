require "laa_crime_forms_common"
require "spec_helper"

class MultiparamDateValidatorSpecForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include LaaCrimeFormsCommon::Validators

  attribute :date, LaaCrimeFormsCommon::Type::MultiparamDate.new

  validates :date, multiparam_date: true
end

RSpec.describe LaaCrimeFormsCommon::Validators::MultiparamDateValidator do
  it "rejects non-numeric day values (e.g. '5a')" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "5a", 2 => "12", 1 => "2024" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_day)).to be(true)
    expect(form.date).to eq({ 3 => "5a", 2 => "12", 1 => "2024" })
  end

  it "rejects non-numeric month values (e.g. '12b')" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "5", 2 => "12b", 1 => "2024" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_month)).to be(true)
  end

  it "accepts valid numeric date parts" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "05", 2 => "12", 1 => "2024" })

    expect(form).to be_valid
    expect(form.date).to be_a(Date)
  end
end
