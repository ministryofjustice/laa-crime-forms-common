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
            def call(claim, show_assessed:, rates:)
              new(claim, show_assessed, rates).call
            end
          end

          def initialize(claim, show_assessed, rates)
            @claim = claim
            @show_assessed = show_assessed
            @rates = rates
          end

          def call
            calculations = work_items.map { Calculators::WorkItem.call(claim, _1, show_assessed:, rates:) }

            types = WORK_TYPES.to_h do |work_type|
              claimed_items = calculations.select { _1[:claimed_work_type] == work_type }
              assessed_items = calculations.select { _1[:assessed_work_type] == work_type } if show_assessed

              [work_type.to_sym, build_summary(claimed_items, assessed_items)]
            end

            types[:total] = build_summary(calculations)

            types
          end

          def work_items
            @work_items ||= claim.work_items.map { Wrappers::WorkItem.new(_1) }
          end

          def build_summary(claimed_items, assessed_items = claimed_items)
            claimed_total_exc_vat = claimed_items.sum(Rational(0, 1)) { _1[:claimed_total_exc_vat] }

            data = {
              claimed_time_spent_in_minutes: claimed_items.sum(Rational(0, 1)) { _1[:claimed_time_spent_in_minutes] },
              claimed_total_exc_vat:,
              claimed_vatable: claim.vat_registered ? claimed_total_exc_vat : Rational(0, 1),
            }

            if show_assessed
              assessed_total_exc_vat = assessed_items.sum(Rational(0, 1)) { _1[:assessed_total_exc_vat] }
              data.merge!(
                assessed_time_spent_in_minutes: assessed_items.sum(Rational(0, 1)) { _1[:assessed_time_spent_in_minutes] },
                assessed_total_exc_vat:,
                assessed_vatable: claim.vat_registered ? assessed_total_exc_vat : Rational(0, 1),
              )
            end

            data
          end

          attr_reader :claim, :show_assessed, :rates
        end
      end
    end
  end
end
