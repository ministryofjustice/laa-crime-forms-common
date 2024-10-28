require_relative "work_types"
require_relative "cost_summary"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class Totals
          class << self
            def call(claim, show_assessed:)
              new(claim, show_assessed).call
            end
          end

          def initialize(claim, show_assessed)
            @claim = claim
            @show_assessed = show_assessed
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
            @work_types ||= Calculators::WorkTypes.call(claim, show_assessed:, rates:)
          end

          def cost_summary
            @cost_summary ||= Calculators::CostSummary.call(claim, work_types, show_assessed:, rates:)
          end

          def totals
            claimed = partial_totals(:claimed)

            return claimed unless show_assessed

            claimed.merge(partial_totals(:assessed))
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

          attr_reader :claim, :show_assessed
        end
      end
    end
  end
end
