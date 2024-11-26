module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class CostSummary
          class << self
            def call(claim, work_types, letters_and_calls, rates:, include_additional_fees: true)
              new(claim, work_types, letters_and_calls, rates, include_additional_fees).call
            end
          end

          def initialize(claim, work_types, letters_and_calls, rates, include_additional_fees)
            @claim = claim
            @work_types = work_types
            @letters_and_calls = letters_and_calls
            @rates = rates
            @include_additional_fees = include_additional_fees
          end

          def call
            include_additional_fees ? fees.merge(additional_fees) : fees
          end

          def fees
            {
              profit_costs: profit_costs_summary_row,
              disbursements: disbursements_summary_row,
              travel: travel_summary_row,
              waiting: waiting_summary_row,
            }
          end

          def additional_fees
            {
              additional_fees: additional_fees_row,
            }
          end

          def additional_fees_row
            calculations = [youth_court_calculation]
            augment_with_vat(calculate_pre_vat_totals(calculations))
          end

          def profit_costs_summary_row
            work_item_rows = work_types.except(:travel, :waiting, :total).values
            augment_with_vat(calculate_pre_vat_totals(work_item_rows + [letters_and_calls, youth_court_calculation]))
          end

          def disbursements_summary_row
            calculations = disbursements.map { Calculators::Disbursement.call(claim, _1, rates:) }
            augment_with_vat(calculate_pre_vat_totals(calculations))
          end

          def travel_summary_row
            augment_with_vat(calculate_pre_vat_totals([work_types[:travel]]))
          end

          def waiting_summary_row
            augment_with_vat(calculate_pre_vat_totals([work_types[:waiting]]))
          end

          def calculate_pre_vat_totals(rows)
            %i[claimed_total_exc_vat
               claimed_vatable
               assessed_total_exc_vat
               assessed_vatable].to_h { |figure| [figure, rows.sum(BigDecimal("0")) { _1[figure] }] }.tap do |basic_data|
              basic_data[:at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group] = rows.any? { _1[:at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group] }
            end
          end

          def augment_with_vat(row)
            claimed_vat = row[:claimed_vatable] * rates.vat
            assessed_vat = row[:assessed_vatable] * rates.vat

            row.merge(
              claimed_vat:,
              assessed_vat:,
              claimed_total_inc_vat: row[:claimed_total_exc_vat] + claimed_vat,
              assessed_total_inc_vat: row[:assessed_total_exc_vat] + assessed_vat,
            )
          end

          def disbursements
            @disbursements ||= claim.disbursements.map { Wrappers::Disbursement.new(_1) }
          end

          attr_reader :claim, :work_types, :letters_and_calls, :rates, :include_additional_fees

        private

          def youth_court_calculation
            @youth_court_calculation ||= Calculators::YouthCourtFee.call(claim, rates:)
          end
        end
      end
    end
  end
end
