require_relative "base"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class WorkItem < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :claimed_time_spent_in_minutes, Integer
          wrap :claimed_work_type, String
          wrap :claimed_uplift_percentage, Integer
          wrap :assessed_time_spent_in_minutes, Integer
          wrap :assessed_work_type, String
          wrap :assessed_uplift_percentage, Integer
        end
      end
    end
  end
end
