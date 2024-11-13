require_relative "autogrant/prior_authority"
require_relative "messages/prior_authority"

module LaaCrimeFormsCommon
  module Hooks
    extend self

    def submission_created(submission, sql_executor, now)
      add_new_version_event(submission, now)

      return unless submission.application_type == "crm4"
      return unless Autogrant::PriorAuthority.autograntable?(submission.latest_version.application, sql_executor)

      add_auto_grant_event(submission, now)
      yield "auto_grant", LaaCrimeFormsCommon::Messages::PriorAuthority::Granted
    end

    def submission_updated(submission, now)
      return unless submission.state == "provider_updated" && submission.application_type == "crm7"

      add_new_version_event(submission, now)
    end

  private

    def add_new_version_event(submission, now)
      submission.events << {
        submission_version: submission.current_version,
        id: SecureRandom.uuid,
        created_at: now,
        details: {},
        updated_at: now,
        event_type: "new_version",
        public: false,
        does_not_constitute_update: false,
      }
    end

    def add_auto_grant_event(submission, now)
      submission.events << {
        submission_version: submission.current_version,
        id: SecureRandom.uuid,
        created_at: now,
        details: {
          field: "state",
          from: "submitted",
          to: "auto_grant",
        },
        updated_at: now,
        event_type: "auto_decision",
        public: false,
        does_not_constitute_update: false,
      }
    end
  end
end
