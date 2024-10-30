module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class LettersAndCalls
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
            letter_and_call_rows = letters_and_calls.map { Calculators::LetterOrCall.call(claim, _1, show_assessed:, rates:) }
            calculate_totals(letter_and_call_rows)
          end

          def calculate_totals(rows)
            figures = %i[claimed_total_exc_vat claimed_vatable]
            figures += %i[assessed_total_exc_vat assessed_vatable] if show_assessed

            figures.to_h { |figure| [figure, rows.sum(BigDecimal("0")) { _1[figure] }] }.tap do |hash|
              hash[:claimed_vat] = hash[:claimed_vatable] * rates.vat
              hash[:assessed_vat] = (hash[:assessed_vatable] * rates.vat) if show_assessed
              hash[:claimed_total_inc_vat] = hash[:claimed_total_exc_vat] + hash[:claimed_vat]
              hash[:assessed_total_inc_vat] = (hash[:assessed_total_exc_vat] + hash[:assessed_vat]) if show_assessed
            end
          end

          def letters_and_calls
            @letters_and_calls ||= claim.letters_and_calls.map { Wrappers::LetterOrCall.new(_1) }
          end

          attr_reader :claim, :show_assessed, :rates
        end
      end
    end
  end
end
