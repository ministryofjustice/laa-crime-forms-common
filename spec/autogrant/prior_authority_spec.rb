require "spec_helper"

require_relative "../../lib/laa_crime_forms_common/autogrant/prior_authority"
require_relative "../../lib/laa_crime_forms_common/autogrant/location_service"

RSpec.describe LaaCrimeFormsCommon::Autogrant::PriorAuthority do
  subject(:autograntable) { described_class.new(data, executor) }

  let(:executor) { :executor }

  before do
    allow(LaaCrimeFormsCommon::Autogrant::LocationService).to receive(:inside_m25?).and_return(true)
  end

  context "when no limit exists for service" do
    let(:data) { { "service_type" => "unknown" } }

    it "is not autograntable" do
      expect(described_class.autograntable?(data, executor)).to eq false
      expect(autograntable).not_to be_autograntable
      expect(autograntable.reason).to eq(:unknown_service)
    end
  end

  context "when limits exists for the service" do
    let(:service_type) { "ae_consultant" }
    let(:additional_costs) { [] }
    let(:quotes) do
      [
        {
          "primary" => true,
        }.merge(primary_quote_cost_details),
      ]
    end
    let(:primary_quote_cost_details) do
      {
        "cost_type" => "per_hour",
        "period" => 60,
        "cost_per_hour" => 10,
      }
    end
    let(:prison_law) { false }
    let(:rep_order_date) { "2021-01-01" }
    let(:ufn) { nil }
    let(:data) do
      {
        "service_type" => service_type,
        "additional_costs" => additional_costs,
        "quotes" => quotes,
        "prison_law" => prison_law,
        "rep_order_date" => rep_order_date,
        "ufn" => ufn,
      }
    end

    context "and is not prison law (uses rep_order_date - 2023/01/02)" do
      context "and date is before limit start date" do
        let(:rep_order_date) { "2012-01-01" }

        it "is not autograntable" do
          expect(autograntable).not_to be_autograntable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end

      context "and date is after limit start date" do
        let(:rep_order_date) { "2024-01-01" }

        it { expect(autograntable).to be_autograntable }

        context "when location service raises an error" do
          before do
            allow(LaaCrimeFormsCommon::Autogrant::LocationService).to receive(:inside_m25?).and_raise(
              LaaCrimeFormsCommon::Autogrant::LocationService::NotFoundError,
            )
          end

          it "returns false" do
            expect(described_class.autograntable?(data, executor)).to eq false
          end
        end
      end
    end

    context "and is prison law (uses ufn - '130324/001')" do
      let(:prison_law) { true }

      context "and date is before limit start date" do
        let(:ufn) { "310111/001" }

        it "is not autograntable" do
          expect(autograntable).not_to be_autograntable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end

      context "and date is after limit start date" do
        let(:ufn) { "310124/001" }

        it { expect(autograntable).to be_autograntable }
      end
    end

    context "and additional costs exists" do
      let(:additional_costs) { [{}] }

      it "is not autograntable" do
        expect(autograntable).not_to be_autograntable
        expect(autograntable.reason).to eq(:additional_costs)
      end
    end

    context "and location is London" do
      context "and unit_type matches service cost type (per_item)" do
        let(:service_type) { "back_calculation" }
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_item",
            "items" => 1,
            "cost_per_item" => 100,
          }
        end

        context "and no travel costs" do
          context "and units and rate is below max limit" do
            it { expect(autograntable).to be_autograntable }
          end

          context "and units is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 2,
                "cost_per_item" => "100",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and rate is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 1,
                "cost_per_item" => "151.21",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context "and travel costs exists" do
          let(:service_type) { "dna_report" }
          let(:primary_quote_cost_details) do
            {
              "cost_type" => "per_item",
              "items" => 1,
              "cost_per_item" => "151.21",
              "travel_time" => 60,
              "travel_cost_per_hour" => "30.0",
            }
          end
          context "and units and rate for quote and travel is below max limit" do
            it { expect(autograntable).to be_autograntable }
          end

          context "and units for quote is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 2,
                "cost_per_item" => "151.21",
                "travel_time" => 60,
                "travel_cost_per_hour" => "30.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and rate for quote is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 1,
                "cost_per_item" => "289.90",
                "travel_time" => 60,
                "travel_cost_per_hour" => "30.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and units for travel is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 1,
                "cost_per_item" => "151.21",
                "travel_time" => 241,
                "travel_cost_per_hour" => "30.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context "and rate for travel is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_item",
                "items" => 1,
                "cost_per_item" => "151.21",
                "travel_time" => 60,
                "travel_cost_per_hour" => "40.01",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context "and unit_type matches service cost type (per_hour)" do
        let(:service_type) { "ae_consultant" }
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_hour",
            "period" => 60,
            "cost_per_hour" => "100.8",
          }
        end

        context "and no travel costs" do
          context "and units and rate is below max limit" do
            it { expect(autograntable).to be_autograntable }
          end

          context "and units is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 481,
                "cost_per_hour" => "100.8",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and rate is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 60,
                "cost_per_hour" => "108.1",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end
        end

        context "and travel costs exists" do
          let(:primary_quote_cost_details) do
            {
              "cost_type" => "per_hour",
              "period" => 480,
              "cost_per_hour" => "100.8",
              "travel_time" => 240,
              "travel_cost_per_hour" => "40.0",
            }
          end

          context "and units and rate for quote and travel is below max limit" do
            it { expect(autograntable).to be_autograntable }
          end

          context "and units for quote is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 481,
                "cost_per_hour" => "100.8",
                "travel_time" => 240,
                "travel_cost_per_hour" => "40.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and rate for quote is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 480,
                "cost_per_hour" => "108.1",
                "travel_time" => 240,
                "travel_cost_per_hour" => "40.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_service_costs)
            end
          end

          context "and units for travel is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 480,
                "cost_per_hour" => "100.8",
                "travel_time" => 241,
                "travel_cost_per_hour" => "40.0",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end

          context "and rate for travel is above units max limit" do
            let(:primary_quote_cost_details) do
              {
                "cost_type" => "per_hour",
                "period" => 480,
                "cost_per_hour" => "100.8",
                "travel_time" => 240,
                "travel_cost_per_hour" => "40.1",
              }
            end

            it "is not autograntable" do
              expect(autograntable).not_to be_autograntable
              expect(autograntable.reason).to eq(:exceed_travel_costs)
            end
          end
        end
      end

      context "and unit_type does not match service cost type" do
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_item",
            "period" => 480,
            "cost_per_hour" => "100.8",
            "travel_time" => 240,
            "travel_cost_per_hour" => "40.0",
          }
        end

        it "is not autograntable" do
          expect(autograntable).not_to be_autograntable
          expect(autograntable.reason).to eq(:unknown_service)
        end
      end
    end

    context "and location is not London" do
      before do
        allow(LaaCrimeFormsCommon::Autogrant::LocationService).to receive(:inside_m25?).and_return(false)
      end

      let(:service_type) { "accident_reconstruction" }

      context "and rate is less than non-London max" do
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_hour",
            "period" => 60,
            "cost_per_hour" => "72.0",
          }
        end
        it { expect(autograntable).to be_autograntable }
      end

      context "and rate is more than non-London max" do
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_hour",
            "period" => 60,
            "cost_per_hour" => "72.1",
          }
        end
        it { expect(autograntable).not_to be_autograntable }
      end

      context "and travel rate is less than non-London max" do
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_hour",
            "period" => 60,
            "cost_per_hour" => "72.0",
            "travel_time" => 60,
            "travel_cost_per_hour" => "36.0",
          }
        end
        it { expect(autograntable).to be_autograntable }
      end

      context "and travel rate is more than non-London max" do
        let(:primary_quote_cost_details) do
          {
            "cost_type" => "per_hour",
            "period" => 60,
            "cost_per_hour" => "72.0",
            "travel_time" => 60,
            "travel_cost_per_hour" => "36.1",
          }
        end
        it { expect(autograntable).not_to be_autograntable }
      end
    end
  end
end
