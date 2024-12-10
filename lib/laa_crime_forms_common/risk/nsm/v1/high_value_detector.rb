require_relative "../../../pricing/nsm"
require_relative "../../../assignment"
require "bigdecimal"

module LaaCrimeFormsCommon
  module Risk
    module Nsm
      module V1
        # This assumes no assessment has taken place for simplicity - so should only be run on
        # pre-adjusted claims
        class HighValueDetector
          def self.call(data)
            new(data).call
          end

          def initialize(data)
            @data = data
          end

          attr_accessor :data

          def call
            totals = LaaCrimeFormsCommon::Pricing::Nsm.totals(build_claim_object)
            threshold = LaaCrimeFormsCommon::Assignment::NSM_HIGH_VALUE_CLAIM_PROFIT_COST_THRESHOLD
            totals[:cost_summary][:profit_costs][:claimed_total_inc_vat] >= threshold
          end

        private

          def build_claim_object
            {
              claim_type: data["claim_type"],
              rep_order_date: (Date.parse(data["rep_order_date"]) if data["rep_order_date"]),
              cntp_date: (Date.parse(data["cntp_date"]) if data["cntp_date"]),
              claimed_youth_court_fee_included: data["include_youth_court_fee"] || false,
              assessed_youth_court_fee_included: false,
              youth_court: data["youth_court"] == "yes",
              plea_category: data["plea_category"],
              vat_registered: data.dig("firm_office", "vat_registered") == "yes",
              work_items: data["work_items"].map { build_work_item_object(_1) },
              letters_and_calls: data["letters_and_calls"].map { build_letter_or_call_object(_1) },
              disbursements: data["disbursements"].map { build_disbursement_object(_1) },
            }
          end

          def build_work_item_object(work_item)
            {
              claimed_time_spent_in_minutes: work_item["time_spent"],
              claimed_work_type: work_item["work_type"],
              claimed_uplift_percentage: work_item["uplift"].to_i,
              assessed_time_spent_in_minutes: 0,
              assessed_work_type: work_item["work_type"],
              assessed_uplift_percentage: 0,
            }
          end

          def build_letter_or_call_object(letter_or_call)
            {
              type: letter_or_call["type"].to_sym,
              claimed_items: letter_or_call["count"],
              claimed_uplift_percentage: letter_or_call["uplift"].to_i,
              assessed_items: 0,
              assessed_uplift_percentage: 0,
            }
          end

          def build_disbursement_object(disbursement)
            {
              disbursement_type: disbursement["disbursement_type"],
              claimed_cost: (BigDecimal(disbursement["total_cost_without_vat"]) if disbursement["total_cost_without_vat"]),
              claimed_miles: (BigDecimal(disbursement["miles"]) if disbursement["miles"]),
              claimed_apply_vat: disbursement["apply_vat"] == "true",
              assessed_cost: 0,
              assessed_miles: BigDecimal(0),
              assessed_apply_vat: false,
            }
          end
        end
      end
    end
  end
end
