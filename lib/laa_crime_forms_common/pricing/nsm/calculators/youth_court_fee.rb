module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class YouthCourtFee
          ELLIGIBLE_DATE = Date.new(2024, 12, 7)
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
            {
              claimed_total_exc_vat:,
              assessed_total_exc_vat:,
              claimed_vatable: claim.vat_registered ? claimed_total_exc_vat : BigDecimal("0"),
              assessed_vatable: claim.vat_registered ? assessed_total_exc_vat : BigDecimal("0"), 
            }
          end

        private

          def claim_date
            case claim.claim_type
            when "non_standard_magistrate"
              claim.rep_order_date
            when "breach_of_injunction"
              claim.cntp_date
            else
              raise "Unrecognised claim type '#{claim.claim_type}'"
            end
          end

          def claimed_total_exc_vat
            claim.claimed_youth_court_fee_included && youth_court_fee_applicable ? rates.additional_fees[:youth_court] : BigDecimal("0")
          end

          def assessed_total_exc_vat
            claim.assessed_youth_court_fee_included ? rates.additional_fees[:youth_court] : BigDecimal("0")
          end
          
          def youth_court_fee_applicable
            [
              claim_date >= ELLIGIBLE_DATE,
              claim.youth_court == "yes",
              %w[category_1a category_2a].include?(claim.plea_category),
            ].all? { |criteria| criteria == true }
          end

          attr_reader :claim, :rates
        end
      end
    end
  end
end
