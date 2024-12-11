require_relative "hooks/nsm"
require_relative "hooks/prior_authority"

module LaaCrimeFormsCommon
  module Hooks
    extend self

    def submission_created(submission, sql_executor, now)
      add_new_version_event(submission, now)

      yieldable = case submission.application_type
                  when "crm4"
                    Hooks::PriorAuthority.submission_created(submission, sql_executor, now)
                  when "crm7"
                    Hooks::Nsm.submission_created(submission)
                  end

      yield(*yieldable) if yieldable
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
  end
end
