require "spec_helper"
require "active_model"

require_relative "../../lib/laa_crime_forms_common/attributes/type/multiparam_date"
require_relative "../../lib/laa_crime_forms_common/validators/multiparam_date_validator"

class MultiparamDateBaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include LaaCrimeFormsCommon::Validators

  attribute :date, LaaCrimeFormsCommon::Type::MultiparamDate.new
end

class MultiparamDateValidatorSpecForm < MultiparamDateBaseForm
  validates :date, multiparam_date: true
end

class MultiparamDateNoPastValidatorSpecForm < MultiparamDateBaseForm
  validates :date, multiparam_date: { allow_past: false, allow_future: true }
end

class MultiparamDateAllowFutureValidatorSpecForm < MultiparamDateBaseForm
  validates :date, multiparam_date: { allow_future: true }
end

RSpec.describe LaaCrimeFormsCommon::Validators::MultiparamDateValidator do
  describe LaaCrimeFormsCommon::Type::MultiparamDate do
    subject(:type) { described_class.new }

    it "returns nil when given nil" do
      expect(type.cast(nil)).to be_nil
    end

    it "returns the date when given a Date" do
      date = Date.new(2024, 1, 1)
      expect(type.cast(date)).to eq(date)
    end

    it "returns the raw hash for numeric but invalid dates" do
      value = { 3 => "31", 2 => "2", 1 => "2024" }
      expect(type.cast(value)).to eq(value)
    end
  end

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

  it "returns early when value is blank" do
    form = MultiparamDateValidatorSpecForm.new(date: nil)
    expect(form).to be_valid
  end

  it "accepts valid numeric date parts" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "05", 2 => "12", 1 => "2024" })

    expect(form).to be_valid
    expect(form.date).to be_a(Date)
  end

  it "accepts valid numeric date parts when given as integers" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => 5, 2 => 12, 1 => 2024 })

    expect(form).to be_valid
    expect(form.date).to be_a(Date)
  end

  it "adds an :invalid error for impossible dates (e.g. Feb 31)" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "31", 2 => "2", 1 => "2024" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid)).to be(true)
  end

  it "adds :invalid_day for out-of-range days" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "32", 2 => "12", 1 => "2024" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_day)).to be(true)
  end

  it "adds :invalid_month for out-of-range months" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "5", 2 => "13", 1 => "2024" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_month)).to be(true)
  end

  it "adds :invalid_year for years that are not 4 digits" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "5", 2 => "12", 1 => "123" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_year)).to be(true)
  end

  it "adds :invalid_year for non-numeric years" do
    form = MultiparamDateValidatorSpecForm.new(date: { 3 => "5", 2 => "12", 1 => "202a" })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :invalid_year)).to be(true)
  end

  it "adds :past_not_allowed when configured to disallow past dates" do
    form = MultiparamDateNoPastValidatorSpecForm.new(date: Date.today - 1)

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :past_not_allowed)).to be(true)
  end

  it "adds :future_not_allowed for future dates by default" do
    form = MultiparamDateValidatorSpecForm.new(date: Date.today + 1)

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :future_not_allowed)).to be(true)
  end

  it "adds :year_too_early for years before the configured earliest_year" do
    form = MultiparamDateValidatorSpecForm.new(date: Date.new(1899, 1, 1))

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :year_too_early)).to be(true)
  end

  it "adds :year_too_late for years after the configured latest_year" do
    form = MultiparamDateAllowFutureValidatorSpecForm.new(date: Date.new(2051, 1, 1))

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:date, :year_too_late)).to be(true)
  end

  it "uses Time.zone when it is configured" do
    original_zone = Time.zone
    Time.zone = "UTC"

    form = MultiparamDateValidatorSpecForm.new(date: Date.today)
    expect(form).to be_valid
  ensure
    Time.zone = original_zone
  end
end
