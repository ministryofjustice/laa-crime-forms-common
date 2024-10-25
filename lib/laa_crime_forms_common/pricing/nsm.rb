require_relative "nsm/rates"
require_relative "nsm/wrappers/claim"
require_relative "nsm/wrappers/work_item"
require_relative "nsm/wrappers/disbursement"
require_relative "nsm/work_item_calculator"
require_relative "nsm/disbursement_calculator"

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

      def calculate_work_item(claim, work_item)
        WorkItemCalculator.call(wrap(claim), Wrappers::WorkItem.new(work_item))
      end

      def calculate_disbursement(claim, disbursement)
        DisbursementCalculator.call(wrap(claim), Wrappers::Disbursement.new(disbursement))
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
