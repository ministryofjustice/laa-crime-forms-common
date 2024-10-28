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
          wrap :rep_order_date, DateOrDateString, default: nil
          wrap :cntp_date, DateOrDateString, default: nil
          wrap :vat_registered, Bool
          wrap :claimed_letters, Integer
          wrap :claimed_calls, Integer
          wrap :assessed_letters, Integer, default: nil
          wrap :assessed_calls, Integer, default: nil
        end
      end
    end
  end
end
