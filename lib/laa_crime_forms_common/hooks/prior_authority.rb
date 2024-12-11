require_relative "../autogrant/prior_authority"
require_relative "../messages/prior_authority"

module LaaCrimeFormsCommon
  module Hooks
    module PriorAuthority
    module_function

      def submission_created(submission, sql_executor, now)
        return unless Autogrant::PriorAuthority.autograntable?(submission.latest_version.application, sql_executor)

        add_auto_grant_event(submission, now)
        ["auto_grant", LaaCrimeFormsCommon::Messages::PriorAuthority::Granted]
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
end
