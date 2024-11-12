require_relative "base"

module LaaCrimeFormsCommon
  module Messages
    module PriorAuthority
      class Granted < Base
        def template
          "d4f3da60-4da5-423e-bc93-d9235ff01a7b"
        end

        def contents
          {
            laa_case_reference: case_reference,
            ufn:,
            defendant_name:,
            service_required:,
            service_provider_details:,
            application_total:,
            date: Time.now.strftime("%-d %B %Y"),
          }
        end
      end
    end
  end
end
