module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class WorkItem
          class << self
            def call(claim, work_item, show_assessed:, rates: Rates.call(claim))
              new(claim, work_item, show_assessed, rates).call
            end
          end

          def initialize(claim, work_item, show_assessed, rates)
            @claim = claim
            @work_item = work_item
            @rates = rates
            @show_assessed = show_assessed
          end

          def call
            claimed = {
              claimed_work_type: work_item.claimed_work_type,
              claimed_time_spent_in_minutes: work_item.claimed_time_spent_in_minutes,
              claimed_subtotal_without_uplift:,
              claimed_total_exc_vat:,
            }

            return claimed unless show_assessed

            claimed.merge(
              assessed_work_type: work_item.assessed_work_type,
              assessed_time_spent_in_minutes: work_item.assessed_time_spent_in_minutes,
              assessed_subtotal_without_uplift:,
              assessed_total_exc_vat:,
            )
          end

        private

          def claimed_subtotal_without_uplift
            @claimed_subtotal_without_uplift ||= Rational(work_item.claimed_time_spent_in_minutes * claimed_rate_per_hour, 60)
          end

          def claimed_total_exc_vat
            claimed_subtotal_without_uplift * claimed_uplift_multiplier
          end

          def claimed_rate_per_hour
            rates.work_items[work_item.claimed_work_type.to_sym]
          end

          def claimed_uplift_multiplier
            Rational(100 + work_item.claimed_uplift_percentage, 100)
          end

          def assessed_subtotal_without_uplift
            @assessed_subtotal_without_uplift ||= Rational(work_item.assessed_time_spent_in_minutes * assessed_rate_per_hour, 60)
          end

          def assessed_total_exc_vat
            assessed_subtotal_without_uplift * assessed_uplift_multiplier
          end

          def assessed_rate_per_hour
            rates.work_items[work_item.assessed_work_type.to_sym]
          end

          def assessed_uplift_multiplier
            Rational(100 + work_item.assessed_uplift_percentage, 100)
          end

          attr_reader :work_item, :claim, :show_assessed, :rates
        end
      end
    end
  end
end
