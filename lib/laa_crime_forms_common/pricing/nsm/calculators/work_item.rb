module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class WorkItem
          class << self
            def call(claim, work_item)
              new(claim, work_item).call
            end
          end

          def initialize(claim, work_item)
            @claim = claim
            @work_item = work_item
          end

          def call
            {
              claimed_subtotal_without_uplift:,
              claimed_total:,
              assessed_subtotal_without_uplift:,
              assessed_total:,
            }
          end

        private

          def claimed_subtotal_without_uplift
            @claimed_subtotal_without_uplift ||= Rational(work_item.claimed_time_spent_in_minutes * claimed_rate_per_hour, 60)
          end

          def claimed_total
            claimed_subtotal_without_uplift * claimed_uplift_multiplier
          end

          def claimed_rate_per_hour
            Rates.call(claim).work_items[work_item.claimed_work_type.to_sym]
          end

          def claimed_uplift_multiplier
            Rational(100 + work_item.claimed_uplift_percentage, 100)
          end

          def assessed_subtotal_without_uplift
            @assessed_subtotal_without_uplift ||= Rational(work_item.assessed_time_spent_in_minutes * assessed_rate_per_hour, 60)
          end

          def assessed_total
            assessed_subtotal_without_uplift * assessed_uplift_multiplier
          end

          def assessed_rate_per_hour
            Rates.call(claim).work_items[work_item.assessed_work_type.to_sym]
          end

          def assessed_uplift_multiplier
            Rational(100 + work_item.assessed_uplift_percentage, 100)
          end

          attr_reader :work_item, :claim
        end
      end
    end
  end
end
