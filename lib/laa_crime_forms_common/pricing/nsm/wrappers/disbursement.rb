require "bigdecimal"
require_relative "base"
require_relative "bool"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class Disbursement < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :disbursement_type, String
          wrap :claimed_cost, BigDecimal, default: nil
          wrap :claimed_miles, BigDecimal, default: nil
          wrap :claimed_apply_vat, Bool
          wrap :assessed_cost, BigDecimal, default: nil
          wrap :assessed_miles, BigDecimal, default: nil
          wrap :assessed_apply_vat, Bool
        end
      end
    end
  end
end
