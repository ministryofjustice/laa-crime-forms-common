require_relative "base"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class LetterOrCall < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :type, Symbol
          wrap :claimed_items, Integer
          wrap :claimed_uplift_percentage, Integer, default: 0
          wrap :assessed_items, Integer, default: nil
          wrap :assessed_uplift_percentage, Integer, default: 0
        end
      end
    end
  end
end
