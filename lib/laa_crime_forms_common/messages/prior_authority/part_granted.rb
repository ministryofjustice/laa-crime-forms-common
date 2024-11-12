require_relative "base"

module LaaCrimeFormsCommon
  module Messages
    module PriorAuthority
      class PartGranted < Base
        def template
          "97c0245f-9fec-4ec1-98cc-c9d392a81254"
        end

        def contents
          {
            laa_case_reference: case_reference,
            ufn:,
            defendant_name:,
            service_required:,
            service_provider_details:,
            application_total:,
            part_grant_total: adjusted_total,
            caseworker_decision_explanation: comments,
            date: Time.now.strftime("%-d %B %Y"),
          }
        end
      end
    end
  end
end
