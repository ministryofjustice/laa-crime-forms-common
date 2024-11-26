require_relative "base"
require_relative "date_or_date_string"
require_relative "bool"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class Claim < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :claim_type, String
          wrap :work_items, Array
          wrap :disbursements, Array
          wrap :letters_and_calls, Array
          wrap :rep_order_date, DateOrDateString, default: nil
          wrap :cntp_date, DateOrDateString, default: nil
          wrap :vat_registered, Bool
          wrap :claimed_youth_court_fee_included, Bool, default: false
          wrap :assessed_youth_court_fee_included, Bool, default: nil
          wrap :youth_court, Bool
          wrap :plea_category, String
        end
      end
    end
  end
end
