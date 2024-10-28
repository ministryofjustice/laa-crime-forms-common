module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class LetterOrCall
          class << self
            def call(claim, letter_or_call)
              new(claim, letter_or_call).call
            end
          end

          def initialize(claim, letter_or_call)
            @claim = claim
            @letter_or_call = letter_or_call
          end

          def call
            {
              claimed_total:,
              assessed_total:,
            }
          end

        private

          def claimed_total
            letter_or_call.claimed_items * cost_per_item
          end

          def assessed_total
            letter_or_call.assessed_items * cost_per_item
          end

          def cost_per_item
            @cost_per_item ||= LaaCrimeFormsCommon::Pricing::Nsm.rates(claim).letters_and_calls[letter_or_call.type.to_sym]
          end

          attr_reader :letter_or_call, :claim
        end
      end
    end
  end
end
