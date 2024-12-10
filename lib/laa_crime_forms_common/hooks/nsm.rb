require_relative "../risk/nsm/v1/high_risk_detector"
require_relative "../risk/nsm/v1/high_value_detector"
require_relative "../risk/nsm/v1/low_risk_detector"

module LaaCrimeFormsCommon
  module Hooks
    module Nsm
      extend self

      def submission_created(submission)
        schema_version = submission.latest_version.json_schema_version
        raise "Don't know how to process schema v#{schema_version}" if schema_version > 1

        is_high_value = high_value?(submission.latest_version)
        submission.application_risk = assess_risk(submission.latest_version, is_high_value)
        add_value_flag(submission.latest_version, is_high_value)

        nil # We do not want to pass an object to be yielded
      end

    private

      def add_value_flag(submission_version, is_high_value)
        submission_version.application["cost_summary"] ||= {}
        submission_version.application["cost_summary"]["high_value"] = is_high_value
        submission_version.save!(touch: false)
      end

      def assess_risk(submission_version, is_high_value)
        return "high" if high_risk?(submission_version.application, is_high_value)
        return "low" if low_risk?(submission_version.application)

        "medium"
      end

      def high_value?(submission_version)
        LaaCrimeFormsCommon::Risk::Nsm::V1::HighValueDetector.call(submission_version.application)
      end

      def high_risk?(data, is_high_value)
        LaaCrimeFormsCommon::Risk::Nsm::V1::HighRiskDetector.call(data, is_high_value)
      end

      def low_risk?(data)
        LaaCrimeFormsCommon::Risk::Nsm::V1::LowRiskDetector.call(data)
      end
    end
  end
end
