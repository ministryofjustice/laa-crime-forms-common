require "spec_helper"
require_relative "../../lib/laa_crime_forms_common/autogrant/location_service"

RSpec.describe LaaCrimeFormsCommon::Autogrant::LocationService do
  describe ".inside_m25?" do
    subject { described_class.inside_m25?(input_postcode, executor) }

    let(:executor) { double(:active_record_connection) }
    let(:query_result) { [{ "st_contains" => inside }] }
    let(:inside) { true }

    let(:os_api_stub) do
      stub_request(:get, "https://api.os.uk/search/names/v1/find?query=#{sent_postcode}&key=TEST_OS_API_KEY").to_return(
        status: 200,
        body: payload.to_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
    end
    let(:input_postcode) { "some postcode" }
    let(:sent_postcode) { "SOMEPOSTCODE" }

    before do
      allow(ENV).to receive(:fetch).with("OS_API_KEY", nil).and_return("TEST_OS_API_KEY")
      allow(executor).to receive(:execute).and_return(query_result)
      os_api_stub
    end

    context "when I provide a London postcode" do
      let(:payload) do
        {
          results: [
            {
              "GAZETTEER_ENTRY" => {
                "ID" => sent_postcode,
                "GEOMETRY_X" => 527_614.0,
                "GEOMETRY_Y" => 175_539.0,
              },
            },
          ],
        }
      end

      it "calls the OS API" do
        subject
        expect(os_api_stub).to have_been_requested
      end

      it "returns what the query says" do
        expect(subject).to be true
      end
    end

    context "when I provide a non-London postcode" do
      let(:payload) do
        {
          results: [
            {
              "GAZETTEER_ENTRY" => {
                "ID" => sent_postcode,
                "GEOMETRY_X" => 613_702.0,
                "GEOMETRY_Y" => 284_209.0,
              },
            },
          ],
        }
      end
      let(:inside) { false }

      it "calls the OS API" do
        subject
        expect(os_api_stub).to have_been_requested
      end

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "when the API returns 2 results" do
      let(:payload) do
        {
          results: [
            {
              "GAZETTEER_ENTRY" => {
                "ID" => sent_postcode,
                "GEOMETRY_X" => 613_702.0, # Outside London coordinates
                "GEOMETRY_Y" => 284_209.0,
              },
            },
            {
              "GAZETTEER_ENTRY" => {
                "ID" => "OTHERPOSTCODE",
                "GEOMETRY_X" => 527_614.0, # Inside London coordinates
                "GEOMETRY_Y" => 175_539.0,
              },
            },
          ],
        }
      end

      let(:inside) { false }

      it "uses the right one, and returns false" do
        expect(subject).to be false
      end
    end

    context "when the API returns unexpected format" do
      let(:payload) do
        { error: "SOmething unexpected" }
      end

      it "raises an appropriate error" do
        expect {
          subject
        }.to raise_error described_class::ResponseError,
                         "OS API returned unexpected format when queried for postcode SOMEPOSTCODE"
      end
    end

    context "when the API returns no match" do
      let(:payload) do
        {
          results: [
            {
              "GAZETTEER_ENTRY" => {
                "ID" => "randompostcode",
                "GEOMETRY_X" => 613_702.0,
                "GEOMETRY_Y" => 284_209.0,
              },
            },
          ],
        }
      end

      it "raises an appropriate error" do
        expect {
          subject
        }.to raise_error described_class::NotFoundError, "OS API returned no matching entry for postcode SOMEPOSTCODE"
      end
    end

    context "when the API match has no coordinates" do
      let(:payload) do
        {
          results: [
            {
              "GAZETTEER_ENTRY" => {
                "ID" => sent_postcode,
              },
            },
          ],
        }
      end

      it "raises an appropriate error" do
        expect {
          subject
        }.to raise_error described_class::InvalidFormatError,
                         "OS API did not provide coordinates in expected format for postcode SOMEPOSTCODE"
      end
    end

    context "when a partial postcode is provided" do
      let(:input_postcode) { "outcode" }
      let(:sent_postcode) { "OUTCODE" }

      context "when the outcode is safely inside London" do
        let(:payload) do
          {
            results: [
              {
                "GAZETTEER_ENTRY" => {
                  "NAME1" => "#{sent_postcode} ABC",
                  "LOCAL_TYPE" => "Postcode",
                  "GEOMETRY_X" => 527_614.0,
                  "GEOMETRY_Y" => 175_539.0,
                },
              },
            ],
          }
        end

        it "returns true" do
          expect(subject).to be true
        end
      end

      context "when the outcode is safely outside London" do
        let(:payload) do
          {
            results: [
              {
                "GAZETTEER_ENTRY" => {
                  "NAME1" => "#{sent_postcode} ABC",
                  "LOCAL_TYPE" => "Postcode",
                  "GEOMETRY_X" => 613_702.0,
                  "GEOMETRY_Y" => 284_209.0,
                },
              },
            ],
          }
        end
        let(:inside) { false }

        it "returns true" do
          expect(subject).to be false
        end
      end

      context "when the outcode straddles the M25" do
        let(:input_postcode) { "rm4" }
        let(:sent_postcode) { "RM4" }
        let(:payload) do
          {
            results: [
              {
                "GAZETTEER_ENTRY" => {
                  "NAME1" => "#{sent_postcode} ABC",
                  "LOCAL_TYPE" => "Postcode",
                  "GEOMETRY_X" => 613_702.0,
                  "GEOMETRY_Y" => 284_209.0,
                },
              },
            ],
          }
        end

        it "raises an appropriate error" do
          expect {
            subject
          }.to raise_error described_class::UnknowablePartialPostcode,
                           "Outcode RM4 could be inside or outside the M25"
        end
      end

      context "when the outcode is not recognised as an outcode" do
        let(:payload) do
          {
            results: [
              {
                "GAZETTEER_ENTRY" => {
                  "NAME1" => "#{sent_postcode} ABC",
                  "LOCAL_TYPE" => "Town",
                  "GEOMETRY_X" => 613_702.0,
                  "GEOMETRY_Y" => 284_209.0,
                },
              },
            ],
          }
        end

        it "raises an appropriate error" do
          expect {
            subject
          }.to raise_error described_class::NotFoundError, "OS API returned no matching entry for postcode OUTCODE"
        end
      end
    end
  end
end
