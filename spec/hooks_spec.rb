require_relative "../lib/laa_crime_forms_common/hooks"
require_relative "../lib/laa_crime_forms_common/autogrant/prior_authority"
require "spec_helper"
require "bigdecimal"

RSpec.describe LaaCrimeFormsCommon::Hooks do
  let(:application_type) { "crm7" }
  let(:submission) do
    double(:submission,
           current_version: 10,
           state:,
           application_type:,
           latest_version:,
           events: [],
           'last_updated_at=': :now,
           'application_risk=': true)
  end
  let(:latest_version) do
    double(:submission_version, application: application_data, json_schema_version:, save!: true)
  end
  let(:json_schema_version) { 1 }
  let(:application_data) do
    { "foo" => "bar" }
  end
  let(:state) { "submitted" }

  describe ".submission_created" do
    let(:executor) { :executor }
    let(:now) { :now }

    context "when application is NSM" do
      let(:application_data) do
        {
          "claim_type" => "non_standard_magistrate",
          "rep_order_date" => "2024-1-1",
          "work_items" => [],
          "letters_and_calls" => [],
          "disbursements" => [],
          "reasons_for_claim" => %w[core_costs_exceed_higher_limit],
        }
      end

      it "adds a new version event" do
        described_class.submission_created(submission, executor, now)
        expect(submission.events.first).to match(
          submission_version: 10,
          id: an_instance_of(String),
          created_at: :now,
          details: {},
          updated_at: :now,
          event_type: "new_version",
          public: false,
          does_not_constitute_update: false,
        )
      end

      it "assigns risk and high value-ness" do
        described_class.submission_created(submission, executor, now)
        expect(submission).to have_received("application_risk=").with("low")
        expect(application_data["cost_summary"]["high_value"]).to eq false
      end

      context "when claim has a medium value" do
        let(:application_data) do
          {
            "claim_type" => "breach_of_injunction",
            "cntp_date" => "2024-1-1",
            "work_items" => [{ "time_spent" => 1000, "uplift" => 0, "work_type" => "attendance_with_counsel" }],
            "letters_and_calls" => [],
            "disbursements" => [],
            "reasons_for_claim" => %w[core_costs_exceed_higher_limit],
          }
        end

        it "assigns risk and high value-ness" do
          described_class.submission_created(submission, executor, now)
          expect(submission).to have_received("application_risk=").with("medium")
          expect(application_data["cost_summary"]["high_value"]).to eq false
        end
      end

      context "when claim has high value" do
        let(:application_data) do
          {
            "claim_type" => "breach_of_injunction",
            "cntp_date" => "2024-1-1",
            "work_items" => [{ "time_spent" => 10_000, "uplift" => 0, "work_type" => "advocacy" }],
            "letters_and_calls" => [{ "type" => "letters", "count" => 100, "uplift" => 100 }],
            "disbursements" => [{ "disbursement_type" => "car", "miles" => BigDecimal(1000) }],
            "reasons_for_claim" => %w[core_costs_exceed_higher_limit],
          }
        end

        it "assigns risk and high value-ness" do
          described_class.submission_created(submission, executor, now)
          expect(submission).to have_received("application_risk=").with("high")
          expect(application_data["cost_summary"]["high_value"]).to eq true
        end
      end

      context "when submission is of type v2" do
        let(:json_schema_version) { 2 }
        it "raises an error" do
          expect { described_class.submission_created(submission, executor, now) }.to raise_error(
            "Don't know how to process schema v2",
          )
        end
      end
    end

    context "when application is PA" do
      let(:application_type) { "crm4" }
      context "when not autograntable" do
        before do
          allow(LaaCrimeFormsCommon::Autogrant::PriorAuthority).to receive(:autograntable?).and_return(false)
        end

        it "only adds one event and does not trigger callback" do
          callback_triggered = false
          described_class.submission_created(submission, executor, now) { callback_triggered = true }
          expect(submission.events.count).to eq 1
          expect(callback_triggered).to eq false
        end
      end

      context "when autograntable" do
        before do
          allow(LaaCrimeFormsCommon::Autogrant::PriorAuthority).to(
            receive(:autograntable?).with(application_data, :executor).and_return(true),
          )
        end

        it "adds another event and triggers a callback" do
          new_state = nil
          described_class.submission_created(submission, executor, now) { new_state = _1 }
          expect(submission.events.count).to eq 2
          expect(new_state).to eq "auto_grant"
          expect(submission.events.last).to match(
            submission_version: 10,
            id: an_instance_of(String),
            created_at: :now,
            details: {
              field: "state",
              from: "submitted",
              to: "auto_grant",
            },
            updated_at: :now,
            event_type: "auto_decision",
            public: false,
            does_not_constitute_update: false,
          )
        end
      end
    end

    context "when application is unknown" do
      let(:application_type) { "crm100" }

      it "does not blow up" do
        expect { described_class.submission_created(submission, executor, now) }.not_to raise_error
      end
    end
  end

  describe ".submission_updated" do
    let(:executor) { :executor }
    let(:now) { :now }
    let(:application_type) { "crm7" }
    let(:state) { "provider_updated" }

    it "adds new version event" do
      described_class.submission_updated(submission, now)
      expect(submission.events.first).to match(
        submission_version: 10,
        id: an_instance_of(String),
        created_at: :now,
        details: {},
        updated_at: :now,
        event_type: "new_version",
        public: false,
        does_not_constitute_update: false,
      )
    end

    it "updates submission last_updated_at" do
      described_class.submission_updated(submission, now)
      expect(submission).to have_received("last_updated_at=").with(:now).once
    end

    context "when not crm7" do
      let(:application_type) { "crm4" }

      it "does not add new version event" do
        described_class.submission_updated(submission, now)
        expect(submission.events.count).to eq 0
      end
    end

    context "when not provider_udpated" do
      let(:state) { "granted" }

      it "does not add new version event" do
        described_class.submission_updated(submission, now)
        expect(submission.events.count).to eq 0
      end
    end
  end
end
