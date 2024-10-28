require_relative "work_types"
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
              cost_summary:,
              totals:,
            }
          end

        private

          def work_types
            @work_types ||= Calculators::WorkTypes.call(claim, rates)
          end

          def cost_summary
            @cost_summary ||= Calculators::CostSummary.call(claim, work_types, rates)
          end

          def totals
            pre_vat = %i[claimed_total_exc_vat
                         claimed_vatable
                         assessed_total_exc_vat
                         assessed_vatable].to_h do |figure|
                           [figure, cost_summary.values.sum(Rational(0, 1)) { _1[figure] }]
                         end
            claimed_vat = pre_vat[:claimed_vatable] * rates.vat
            assessed_vat = pre_vat[:assessed_vatable] * rates.vat

            pre_vat.merge(
              claimed_vat:,
              assessed_vat:,
              claimed_total_inc_vat: pre_vat[:claimed_total_exc_vat] + claimed_vat,
              assessed_total_inc_vat: pre_vat[:assessed_total_exc_vat] + assessed_vat,
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
