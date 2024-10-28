require_relative "nsm/rates"
require_relative "nsm/wrappers/claim"
require_relative "nsm/wrappers/disbursement"
require_relative "nsm/wrappers/letter_or_call"
require_relative "nsm/wrappers/work_item"
require_relative "nsm/calculators/disbursement"
require_relative "nsm/calculators/letter_or_call"
require_relative "nsm/calculators/work_item"

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
        Calculators::WorkItem.call(wrap(claim), Wrappers::WorkItem.new(work_item))
      end

      def calculate_disbursement(claim, disbursement)
        Calculators::Disbursement.call(wrap(claim), Wrappers::Disbursement.new(disbursement))
      end

      def calculate_letter_or_call(claim, letter_or_call)
        Calculators::LetterOrCall.call(wrap(claim), Wrappers::LetterOrCall.new(letter_or_call))
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
