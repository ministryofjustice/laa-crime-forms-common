require_relative "nsm/rates"
require_relative "nsm/wrappers/claim"
require_relative "nsm/wrappers/disbursement"
require_relative "nsm/wrappers/letter_or_call"
require_relative "nsm/wrappers/work_item"
require_relative "nsm/calculators/disbursement"
require_relative "nsm/calculators/letter_or_call"
require_relative "nsm/calculators/totals"
require_relative "nsm/calculators/work_item"
require_relative "nsm/calculators/youth_court_fee"

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
        deep_round(Calculators::WorkItem.call(wrap(claim), Wrappers::WorkItem.new(work_item)))
      end

      def calculate_disbursement(claim, disbursement)
        deep_round(Calculators::Disbursement.call(wrap(claim), Wrappers::Disbursement.new(disbursement)))
      end

      def calculate_letter_or_call(claim, letter_or_call)
        deep_round(Calculators::LetterOrCall.call(wrap(claim), Wrappers::LetterOrCall.new(letter_or_call)))
      end

      def totals(claim)
        deep_round(Calculators::Totals.call(wrap(claim)))
      end

    private

      def wrap(claim)
        Wrappers::Claim.new(claim)
      end

      def deep_round(object)
        case object
        when Hash
          object.transform_values { deep_round(_1) }
        when Integer
          object
        when Numeric
          # At the point where no more maths is going to be done, we convert to the most readable figure at the level of
          # accuracy needed
          object.round(2).to_f
        else
          object
        end
      end
    end
  end
end
