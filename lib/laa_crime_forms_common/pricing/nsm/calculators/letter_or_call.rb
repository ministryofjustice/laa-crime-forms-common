module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class LetterOrCall
          class << self
            def call(claim, letter_or_call, show_assessed:, rates: Rates.call(claim))
              new(claim, letter_or_call, show_assessed, rates).call
            end
          end

          def initialize(claim, letter_or_call, show_assessed, rates)
            @claim = claim
            @letter_or_call = letter_or_call
            @show_assessed = show_assessed
            @rates = rates
          end

          def call
            claimed = {
              claimed_subtotal_without_uplift:,
              claimed_total_exc_vat:,
              claimed_vatable: claim.vat_registered ? claimed_total_exc_vat : BigDecimal("0"),
            }

            return claimed unless show_assessed

            claimed.merge(
              assessed_subtotal_without_uplift:,
              assessed_total_exc_vat:,
              assessed_vatable: claim.vat_registered ? assessed_total_exc_vat : BigDecimal("0"),
            )
          end

        private

          def claimed_subtotal_without_uplift
            @claimed_subtotal_without_uplift ||= letter_or_call.claimed_items * cost_per_item
          end

          def claimed_uplift_multiplier
            Rational(100 + letter_or_call.claimed_uplift_percentage, 100)
          end

          def claimed_total_exc_vat
            claimed_uplift_multiplier * claimed_subtotal_without_uplift
          end

          def assessed_subtotal_without_uplift
            @assessed_subtotal_without_uplift ||= letter_or_call.assessed_items * cost_per_item
          end

          def assessed_uplift_multiplier
            Rational(100 + letter_or_call.assessed_uplift_percentage, 100)
          end

          def assessed_total_exc_vat
            assessed_uplift_multiplier * assessed_subtotal_without_uplift
          end

          def cost_per_item
            @cost_per_item ||= rates.letters_and_calls[letter_or_call.type.to_sym]
          end

          attr_reader :letter_or_call, :claim, :show_assessed, :rates
        end
      end
    end
  end
end
