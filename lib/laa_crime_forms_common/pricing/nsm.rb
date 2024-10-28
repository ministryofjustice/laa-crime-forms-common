require_relative "nsm/rates"
require_relative "nsm/wrappers/claim"
require_relative "nsm/wrappers/disbursement"
require_relative "nsm/wrappers/letter_or_call"
require_relative "nsm/wrappers/work_item"
require_relative "nsm/calculators/disbursement"
require_relative "nsm/calculators/letter_or_call"
require_relative "nsm/calculators/totals"
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

      def calculate_work_item(claim, work_item, show_assessed:)
        deep_round(Calculators::WorkItem.call(wrap(claim), Wrappers::WorkItem.new(work_item), show_assessed:))
      end

      def calculate_disbursement(claim, disbursement, show_assessed:)
        deep_round(Calculators::Disbursement.call(wrap(claim), Wrappers::Disbursement.new(disbursement), show_assessed:))
      end

      def calculate_letter_or_call(claim, letter_or_call, show_assessed:)
        deep_round(Calculators::LetterOrCall.call(wrap(claim), Wrappers::LetterOrCall.new(letter_or_call), show_assessed:))
      end

      def totals(claim, show_assessed:)
        deep_round(Calculators::Totals.call(wrap(claim), show_assessed:))
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
          object.to_f.round(2)
        else
          object
        end
      end
    end
  end
end
