module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class Disbursement
          class << self
            def call(claim, disbursement, show_assessed:, rates: Rates.call(claim))
              new(claim, disbursement, show_assessed, rates).call
            end
          end

          def initialize(claim, disbursement, show_assessed, rates)
            @claim = claim
            @disbursement = disbursement
            @rates = rates
            @show_assessed = show_assessed
          end

          def call
            claimed = {
              claimed_total_exc_vat:,
              claimed_vatable:,
              claimed_vat:,
              claimed_total_inc_vat:,
            }

            return claimed unless show_assessed

            claimed.merge(
              assessed_total_exc_vat:,
              assessed_vatable:,
              assessed_vat:,
              assessed_total_inc_vat:,
            )
          end

        private

          def claimed_total_exc_vat
            @claimed_total_exc_vat ||= if disbursement.disbursement_type == "other"
                                         disbursement.claimed_cost
                                       else
                                         disbursement.claimed_miles * cost_per_mile
                                       end
          end

          def assessed_total_exc_vat
            if disbursement.disbursement_type == "other"
              disbursement.assessed_cost
            else
              disbursement.assessed_miles * cost_per_mile
            end
          end

          def cost_per_mile
            @cost_per_mile ||= rates.disbursements[disbursement.disbursement_type.to_sym]
          end

          def claimed_vatable
            @claimed_vatable ||= disbursement.claimed_apply_vat ? claimed_total_exc_vat : BigDecimal("0")
          end

          def claimed_vat
            @claimed_vat ||= claimed_vatable * rates.vat
          end

          def assessed_vatable
            @assessed_vatable ||= disbursement.assessed_apply_vat ? assessed_total_exc_vat : BigDecimal("0")
          end

          def assessed_vat
            @assessed_vat ||= assessed_vatable * rates.vat
          end

          def claimed_total_inc_vat
            claimed_total_exc_vat + claimed_vat
          end

          def assessed_total_inc_vat
            assessed_total_exc_vat + assessed_vat
          end

          attr_reader :disbursement, :claim, :show_assessed, :rates
        end
      end
    end
  end
end
