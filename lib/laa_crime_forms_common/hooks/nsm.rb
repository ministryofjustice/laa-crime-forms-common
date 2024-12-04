module LaaCrimeFormsCommon
  module Hooks
    module Nsm
      extend self

      def submission_created(submission)
        submission.risk = assess_risk(submission.latest_version)
        add_value_flag(submission.latest_version)
      end

      def add_value_flag(submission_version)
        is_high_value = calculate_high_value(submission_version)
        submission_version['cost_summary'] ||= {}
        submission_version['cost_summary']['high_value'] = is_high_value
      end
    end
  end
end
