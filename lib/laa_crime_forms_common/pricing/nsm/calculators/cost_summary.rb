module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class CostSummary
          class << self
            def call(claim, work_types, rates)
              new(claim, work_types, rates).call
            end
          end

          def initialize(claim, work_types, rates)
            @claim = claim
            @work_types = work_types
            @rates = rates
          end

          def call
            {
              profit_costs: profit_costs_summary_row,
              disbusements: disbursements_summary_row,
              travel: travel_summary_row,
              waiting: waiting_summary_row,
            }
          end

          def profit_costs_summary_row
            work_item_rows = work_types.except(:travel, :waiting).values
            letter_and_call_rows = letters_and_calls.map { Calculators::LetterOrCall.call(claim, _1, rates) }
            rows = work_item_rows + letter_and_call_rows
            augment_with_vat(
              claimed_total_exc_vat: rows.sum(Rational(0, 1)) { _1[:claimed_total_exc_vat] },
              assessed_total_exc_vat: rows.sum(Rational(0, 1)) { _1[:assessed_total_exc_vat] },
            )
          end

          def disbursements_summary_row
            calculations = disbursements.map { Calculators::Disbursement.call(claim, _1, rates) }
            %i[claimed_total_exc_vat
               claimed_vatable
               claimed_vat
               claimed_total_inc_vat
               assessed_total_exc_vat
               assessed_vatable
               assessed_vat
               assessed_total_inc_vat].to_h do |figure|
                 [figure, calculations.sum(BigDecimal("0")) { _1[figure] }]
               end
          end

          def travel_summary_row
            augment_with_vat(work_types[:travel].dup.slice(:claimed_total_exc_vat, :assessed_total_exc_vat))
          end

          def waiting_summary_row
            augment_with_vat(work_types[:waiting].dup.slice(:claimed_total_exc_vat, :assessed_total_exc_vat))
          end

          def augment_with_vat(row)
            if claim.vat_registered
              claimed_vatable = row[:claimed_total_exc_vat]
              claimed_vat = claimed_vatable * rates.vat
              assessed_vatable = row[:assessed_total_exc_vat]
              assessed_vat = assessed_vatable * rates.vat
            end

            row.merge(
              claimed_vatable: claimed_vatable || Rational(0, 1),
              claimed_vat: claimed_vat || Rational(0, 1),
              claimed_total_inc_vat: row[:claimed_total_exc_vat] + (claimed_vat || Rational(0, 1)),
              assessed_vatable: assessed_vatable || Rational(0, 1),
              assessed_vat: assessed_vat || Rational(0, 1),
              assessed_total_inc_vat: row[:assessed_total_exc_vat] + (assessed_vat || Rational(0, 1)),
            )
          end

          def letters_and_calls
            [
              Wrappers::LetterOrCall.new(type: :letter, claimed_items: claim.claimed_letters, assessed_items: claim.assessed_letters),
              Wrappers::LetterOrCall.new(type: :call, claimed_items: claim.claimed_calls, assessed_items: claim.assessed_calls),
            ]
          end

          def disbursements
            @disbursements ||= claim.disbursements.map { Wrappers::Disbursement.new(_1) }
          end

          attr_reader :claim, :work_types, :rates
        end
      end
    end
  end
end
