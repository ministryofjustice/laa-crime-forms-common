require_relative "work_types"
require_relative "letters_and_calls"
require_relative "cost_summary"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class Totals
          class << self
            def call(claim)
              new(claim).call
            end
          end

          def initialize(claim)
            @claim = claim
          end

          def call
            {
              work_types:,
              letters_and_calls:,
              cost_summary:,
              totals:,
            }
          end

        private

          def work_types
            @work_types ||= Calculators::WorkTypes.call(claim, rates:)
          end

          def letters_and_calls
            @letters_and_calls ||= Calculators::LettersAndCalls.call(claim, rates:)
          end

          def cost_summary
            @cost_summary ||= Calculators::CostSummary.call(claim, work_types, letters_and_calls, rates:, include_additional_fees: false)
          end

          def totals
            partial_totals(:claimed).merge(partial_totals(:assessed))
          end

          def partial_totals(prefix)
            pre_vat = %i[total_exc_vat vatable].to_h do |suffix|
              figure = "#{prefix}_#{suffix}".to_sym
              [figure, cost_summary.values.sum(Rational(0, 1)) { _1[figure] }]
            end

            vat = pre_vat[:"#{prefix}_vatable"] * rates.vat

            pre_vat.merge(
              "#{prefix}_vat": vat,
              "#{prefix}_total_inc_vat": pre_vat[:"#{prefix}_total_exc_vat"] + vat,
            )
          end

          def rates
            @rates ||= Rates.call(claim)
          end

          attr_reader :claim
        end
      end
    end
  end
end
