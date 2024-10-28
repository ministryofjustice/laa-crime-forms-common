require_relative "base"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class LetterOrCall < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :type, Symbol
          wrap :claimed_items, Integer
          wrap :assessed_items, Integer, default: nil
        end
      end
    end
  end
end
