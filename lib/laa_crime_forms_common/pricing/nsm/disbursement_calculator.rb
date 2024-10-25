module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      class DisbursementCalculator
        class << self
          def call(claim, disbursement)
            new(claim, disbursement).call
          end
        end

        def initialize(claim, disbursement)
          @claim = claim
          @disbursement = disbursement
        end

        def call
          {
            claimed_total:,
            assessed_total:,
          }
        end

      private

        def claimed_total
          if disbursement.disbursement_type == "other"
            disbursement.claimed_cost
          else
            disbursement.claimed_miles * cost_per_mile
          end
        end

        def assessed_total
          if disbursement.disbursement_type == "other"
            disbursement.assessed_cost
          else
            disbursement.assessed_miles * cost_per_mile
          end
        end

        def cost_per_mile
          @cost_per_mile ||= LaaCrimeFormsCommon::Pricing::Nsm.rates(claim).disbursements[disbursement.disbursement_type.to_sym]
        end

        attr_reader :disbursement, :claim
      end
    end
  end
end
