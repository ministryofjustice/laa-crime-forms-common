module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class LetterOrCall
          class << self
            def call(claim, letter_or_call, rates = Rates.call(claim))
              new(claim, letter_or_call, rates).call
            end
          end

          def initialize(claim, letter_or_call, rates)
            @claim = claim
            @letter_or_call = letter_or_call
            @rates = rates
          end

          def call
            {
              claimed_total_exc_vat:,
              assessed_total_exc_vat:,
            }
          end

        private

          def claimed_total_exc_vat
            letter_or_call.claimed_items * cost_per_item
          end

          def assessed_total_exc_vat
            letter_or_call.assessed_items * cost_per_item
          end

          def cost_per_item
            @cost_per_item ||= rates.letters_and_calls[letter_or_call.type.to_sym]
          end

          attr_reader :letter_or_call, :claim, :rates
        end
      end
    end
  end
end
