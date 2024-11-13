require_relative "base"

module LaaCrimeFormsCommon
  module Messages
    module PriorAuthority
      class Rejected < Base
        def template
          "81e9222e-c6bd-4fba-91ff-d90d3d61af87"
        end

        def contents
          {
            laa_case_reference: case_reference,
            ufn:,
            defendant_name:,
            application_total:,
            caseworker_decision_explanation: comments,
            date: Time.now.strftime("%-d %B %Y"),
          }
        end
      end
    end
  end
end
