require_relative "../lib/laa_crime_forms_common/hooks"
require_relative "../lib/laa_crime_forms_common/autogrant/prior_authority"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::Hooks do
  let(:application_type) { "crm7" }
  let(:submission) do
    double(:submission, current_version: 10, state:, application_type:, latest_version:, events: [])
  end
  let(:latest_version) { double(:submission_version, application: :application) }
  let(:state) { "submitted" }

  describe ".submission_created" do
    let(:executor) { :executor }
    let(:now) { :now }

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
            receive(:autograntable?).with(:application, :executor).and_return(true),
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
