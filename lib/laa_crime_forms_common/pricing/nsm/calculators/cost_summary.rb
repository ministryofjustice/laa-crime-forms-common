module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class CostSummary
          class << self
            def call(claim, work_types, show_assessed:, rates:)
              new(claim, work_types, show_assessed, rates).call
            end
          end

          def initialize(claim, work_types, show_assessed, rates)
            @claim = claim
            @work_types = work_types
            @show_assessed = show_assessed
            @rates = rates
          end

          def call
            {
              profit_costs: profit_costs_summary_row,
              disbursements: disbursements_summary_row,
              travel: travel_summary_row,
              waiting: waiting_summary_row,
            }
          end

          def profit_costs_summary_row
            work_item_rows = work_types.except(:travel, :waiting, :total).values
            letter_and_call_rows = letters_and_calls.map { Calculators::LetterOrCall.call(claim, _1, show_assessed:, rates:) }
            augment_with_vat(calculate_pre_vat_totals(work_item_rows + letter_and_call_rows))
          end

          def disbursements_summary_row
            calculations = disbursements.map { Calculators::Disbursement.call(claim, _1, show_assessed:, rates:) }
            augment_with_vat(calculate_pre_vat_totals(calculations))
          end

          def travel_summary_row
            augment_with_vat(calculate_pre_vat_totals([work_types[:travel]]))
          end

          def waiting_summary_row
            augment_with_vat(calculate_pre_vat_totals([work_types[:waiting]]))
          end

          def calculate_pre_vat_totals(rows)
            figures = %i[claimed_total_exc_vat claimed_vatable]
            figures += %i[assessed_total_exc_vat assessed_vatable] if show_assessed

            figures.to_h { |figure| [figure, rows.sum(BigDecimal("0")) { _1[figure] }] }.tap do |basic_data|
              basic_data[:group_changes] = rows.any? { _1[:cost_summary_group_changes] } if show_assessed
            end
          end

          def augment_with_vat(row)
            claimed_vat = row[:claimed_vatable] * rates.vat
            assessed_vat = row[:assessed_vatable] * rates.vat if show_assessed

            new_data = {
              claimed_vat:,
              claimed_total_inc_vat: row[:claimed_total_exc_vat] + claimed_vat,
            }

            if show_assessed
              new_data.merge!(
                assessed_vat:,
                assessed_total_inc_vat: row[:assessed_total_exc_vat] + assessed_vat,
              )
            end

            row.merge(new_data)
          end

          def letters_and_calls
            @letters_and_calls ||= claim.letters_and_calls.map { Wrappers::LetterOrCall.new(_1) }
          end

          def disbursements
            @disbursements ||= claim.disbursements.map { Wrappers::Disbursement.new(_1) }
          end

          attr_reader :claim, :work_types, :show_assessed, :rates
        end
      end
    end
  end
end
