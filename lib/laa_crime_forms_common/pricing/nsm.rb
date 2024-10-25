require_relative "nsm/rates"
require_relative "nsm/wrappers/claim"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      extend self
      # For a given claim, returns lists of:
      # - work type prices per hour
      # - disbursement prices per mile
      # - letter and call prices per item
      def rates(claim)
        Rates.call(wrap(claim))
      end

      def calculate_work_item(_claim, _work_item)
        nil
      end

      def calculate_disbursement(_claim, _disbursement)
        nil
      end

      def calculate_letter_or_call(_claim, _letter_or_call)
        nil
      end

      def totals(_claim)
        nil
      end

    private

      def wrap(claim)
        Wrappers::Claim.new(claim)
      end
    end
  end
end
