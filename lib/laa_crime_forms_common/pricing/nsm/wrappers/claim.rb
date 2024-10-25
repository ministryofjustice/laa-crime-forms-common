require_relative "base"
require_relative "stringy_date"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class Claim < LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::Base
          wrap :claim_type, String
          wrap :work_items, Array
          wrap :disbursements, Array
          wrap :rep_order_date, StringyDate, default: nil
          wrap :cntp_date, StringyDate, default: nil
        end
      end
    end
  end
end
