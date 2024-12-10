module LaaCrimeFormsCommon
  module Risk
    module Nsm
      module V1
        class HighRiskDetector
          def self.call(data, is_high_value)
            new(data, is_high_value).call
          end

          def initialize(data, is_high_value)
            @data = data
            @is_high_value = is_high_value
          end

          attr_accessor :data, :is_high_value

          def call
            is_high_value ||
              counsel_or_agent ||
              high_risk_reason_for_claim
          end

          def counsel_or_agent
            [data["assigned_counsel"], data["unassigned_counsel"], data["agent_instructed"]].include?("yes")
          end

          def high_risk_reason_for_claim
            (data["reasons_for_claim"] & %w[enhanced_rates_claimed extradition representation_order_withdrawn]).any?
          end
        end
      end
    end
  end
end
