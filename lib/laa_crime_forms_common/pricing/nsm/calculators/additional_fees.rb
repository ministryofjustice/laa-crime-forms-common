module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Calculators
        class AdditionalFees
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
              youth_court_fee:,
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

          def youth_court_fee
            claim.youth_court_fee_claimed && youth_court_fee_applicable ? rates.additional_fees[:youth_court] : BigDecimal("0")
          end

          def youth_court_fee_applicable
            [
              claim_date >= ELLIGIBLE_DATE,
              claim.youth_court == "yes",
              %w[category_1a category_2a].include(claim.plea_category),
            ].all? { |criteria| criteria == true }
          end

          attr_reader :claim, :rates
        end
      end
    end
  end
end
