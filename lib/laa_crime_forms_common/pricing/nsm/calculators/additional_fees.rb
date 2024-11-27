module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class AdditionalFees
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
            {
              youth_court_fee: calculate_totals([youth_court_fee_row]),
              total: calculate_totals(additional_fee_rows),
            }
          end

          def additional_fee_rows
            [youth_court_fee_row]
          end

          def youth_court_fee_row
            @youth_court_fee_row ||= Calculators::YouthCourtFee.call(claim, rates:)
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

          attr_reader :claim, :rates
        end
      end
    end
  end
end
