module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class LettersAndCalls
          class << self
            def call(claim, rates: Rates.call(claim))
              new(claim, rates).call
            end
          end

          def initialize(claim, rates)
            @claim = claim
            @rates = rates
          end

          def call
            letter_and_call_rows = letters_and_calls.map { Calculators::LetterOrCall.call(claim, _1, rates:) }
            calculate_totals(letter_and_call_rows)
          end

          def calculate_totals(rows)
            %i[claimed_total_exc_vat
               claimed_vatable
               assessed_total_exc_vat
               assessed_vatable].to_h { |figure| [figure, rows.sum(BigDecimal("0")) { _1[figure] }] }
                                .tap do |hash|
              hash[:claimed_vat] = hash[:claimed_vatable] * rates.vat
              hash[:assessed_vat] = (hash[:assessed_vatable] * rates.vat)
              hash[:claimed_total_inc_vat] = hash[:claimed_total_exc_vat] + hash[:claimed_vat]
              hash[:assessed_total_inc_vat] = (hash[:assessed_total_exc_vat] + hash[:assessed_vat])
            end
          end

          def letters_and_calls
            @letters_and_calls ||= claim.letters_and_calls.map { Wrappers::LetterOrCall.new(_1) }
          end

          attr_reader :claim, :rates
        end
      end
    end
  end
end
