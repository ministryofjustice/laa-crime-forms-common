module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class WorkTypes
          WORK_TYPES = %w[
            travel
            waiting
            attendance_with_counsel
            attendance_without_counsel
            preparation
            advocacy
          ].freeze

          class << self
            def call(claim, rates:)
              new(claim, rates).call
            end
          end

          def initialize(claim, rates)
            @claim = claim
            @rates = rates
          end

          def call
            calculations = work_items.map { Calculators::WorkItem.call(claim, _1, rates:) }
            # rounded_types used for totals to ensure they're summed and rounded per work item type before totalling
            rounded_types = []
            types = WORK_TYPES.to_h do |work_type|
              claimed_items = calculations.select { _1[:claimed_work_type] == work_type }
              assessed_items = calculations.select { _1[:assessed_work_type] == work_type }
              formatted_items = build_summary(claimed_items, assessed_items)
              rounded_types << formatted_items
              [work_type.to_sym, formatted_items]
            end
            types[:total] = add_vat(build_summary(calculations, calculations, rounded_types))
            types
          end

          def work_items
            @work_items ||= claim.work_items.map { Wrappers::WorkItem.new(_1) }
          end

          def build_summary(claimed_items, assessed_items = claimed_items, summarized_items = nil)
            if summarized_items.nil?
              claimed_total_exc_vat = calculated_summation(claimed_items).round(2)
              assessed_total_exc_vat = calculated_summation(assessed_items, :assessed).round(2)
            else
              claimed_total_exc_vat = summarized_items.sum(Rational(0, 1)) { _1[:claimed_total_exc_vat] }.round(2)
              assessed_total_exc_vat = summarized_items.sum(Rational(0, 1)) { _1[:assessed_total_exc_vat] }.round(2)
            end
            {
              claimed_time_spent_in_minutes: claimed_items.sum(Rational(0, 1)) { _1[:claimed_time_spent_in_minutes] },
              claimed_total_exc_vat:,
              claimed_vatable: claim.vat_registered ? claimed_total_exc_vat : Rational(0, 1),
              assessed_time_spent_in_minutes: assessed_items.sum(Rational(0, 1)) { _1[:assessed_time_spent_in_minutes] },
              assessed_total_exc_vat:,
              assessed_vatable: claim.vat_registered ? assessed_total_exc_vat : Rational(0, 1),
              at_least_one_claimed_work_item_assessed_as_different_type: claimed_items.any? { _1[:claimed_work_type] != _1[:assessed_work_type] },
              at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: claimed_items.any? { cost_summary_group_changed?(_1) },
            }
          end

          def cost_summary_group_changed?(work_item_calculation)
            cost_summary_group(work_item_calculation[:claimed_work_type]) != cost_summary_group(work_item_calculation[:assessed_work_type])
          end

          def cost_summary_group(work_type)
            return work_type if %w[travel waiting].include?(work_type)

            "profit_costs"
          end

          def add_vat(hash)
            claimed_vat = hash[:claimed_vatable] * rates.vat
            assessed_vat = hash[:assessed_vatable] * rates.vat
            hash.merge(
              claimed_vat:,
              assessed_vat:,
              claimed_total_inc_vat: hash[:claimed_total_exc_vat] + claimed_vat,
              assessed_total_inc_vat: hash[:assessed_total_exc_vat] + assessed_vat,
            )
          end

          attr_reader :claim, :rates

        private

          def calculated_summation(items, eval_type = :claimed)
            return Rational(0, 1) if items.empty?

            total_time_spent = items.sum(Rational(0, 1)) { _1["#{eval_type}_time_spent_in_minutes".to_sym] }
            total_uplift_time = items.sum(Rational(0, 1)) { _1["#{eval_type}_time_spent_in_minutes".to_sym] * (1 - _1["#{eval_type}_uplift_percentage".to_sym].to_f) / 100 }
            rate = rates.work_items[items.first[:claimed_work_type].to_sym]
            Rational(total_time_spent * rate, 60).round(3) + Rational(total_uplift_time * rate, 60).round(3)
          end
        end
      end
    end
  end
end
