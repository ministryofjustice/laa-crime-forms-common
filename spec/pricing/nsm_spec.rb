require "bigdecimal"
require "spec_helper"
require_relative "../../lib/laa_crime_forms_common/pricing/nsm"

RSpec.describe LaaCrimeFormsCommon::Pricing::Nsm do
  describe "#rates" do
    it "returns relevant rates for a valid claim" do
      claim = { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" }
      ret = described_class.rates(claim)
      expect(ret).to be_a(LaaCrimeFormsCommon::Pricing::Nsm::Rates)
    end

    it "raises on invalid data" do
      claim = { claim_type: "unknown" }
      expect { described_class.rates(claim) }.to raise_error "Unrecognised claim type 'unknown'"
    end
  end

  describe "#calculate_work_item" do
    context "when showing assessed values" do
      let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }
      let(:work_item) do
        {
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_uplift_percentage: 20,
          assessed_time_spent_in_minutes: 25,
          assessed_work_type: "travel",
          assessed_uplift_percentage: 85,
        }
      end

      it "returns calculated values" do
        expect(described_class.calculate_work_item(claim, work_item, show_assessed: true)).to eq({
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_subtotal_without_uplift: 54.52,
          claimed_total_exc_vat: 65.42,
          assessed_time_spent_in_minutes: 25,
          assessed_work_type: "travel",
          assessed_subtotal_without_uplift: 11.5,
          assessed_total_exc_vat: 21.28,
        })
      end

      it "errors on invalid data" do
        work_item = {
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_uplift_percentage: nil,
          assessed_time_spent_in_minutes: 25.2,
          assessed_work_type: "travel",
          assessed_uplift_percentage: 85,
        }

        expect { described_class.calculate_work_item(claim, work_item, show_assessed: true) }.to raise_error(
          "'claimed_uplift_percentage' in Hash is nil, but must not be",
        )
      end
    end

    context "when not showing assessed data" do
      let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }
      let(:work_item) do
        {
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_uplift_percentage: 20,
        }
      end

      it "returns calculated values" do
        expect(described_class.calculate_work_item(claim, work_item, show_assessed: false)).to eq({
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_subtotal_without_uplift: 54.52,
          claimed_total_exc_vat: 65.42,
        })
      end
    end
  end

  describe "#calculate_disbursement" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10" } }

    context 'when disbursement is "other" type' do
      let(:disbursement) do
        {
          disbursement_type: "other",
          claimed_cost: BigDecimal("123.45"),
          assessed_cost: BigDecimal("85.67"),
          claimed_miles: nil,
          assessed_miles: nil,
          claimed_apply_vat: true,
          assessed_apply_vat: false,
        }
      end

      it "returns provided values" do
        expect(described_class.calculate_disbursement(claim, disbursement, show_assessed: true)).to eq({
          assessed_total_exc_vat: 85.67,
          assessed_total_inc_vat: 85.67,
          assessed_vat: 0.0,
          assessed_vatable: 0.0,
          claimed_total_exc_vat: 123.45,
          claimed_total_inc_vat: 148.14,
          claimed_vat: 24.69,
          claimed_vatable: 123.45,
        })
      end
    end

    context "when disbursement is miles-based type" do
      let(:disbursement) do
        {
          disbursement_type: "car",
          claimed_cost: nil,
          assessed_cost: nil,
          claimed_miles: BigDecimal("12.3"),
          assessed_miles: BigDecimal("12.2"),
          claimed_apply_vat: false,
          assessed_apply_vat: true,
        }
      end

      it "returns calculated values" do
        expect(described_class.calculate_disbursement(claim, disbursement, show_assessed: true)).to eq({
          assessed_total_exc_vat: 5.49,
          assessed_total_inc_vat: 6.59,
          assessed_vat: 1.1,
          assessed_vatable: 5.49,
          claimed_total_exc_vat: 5.54,
          claimed_total_inc_vat: 5.54,
          claimed_vat: 0.0,
          claimed_vatable: 0.0,
        })
      end

      context "when not showing assessed values" do
        let(:disbursement) do
          {
            disbursement_type: "car",
            claimed_cost: nil,
            claimed_miles: BigDecimal("12.3"),
            claimed_apply_vat: false,
          }
        end

        it "returns calculated values" do
          expect(described_class.calculate_disbursement(claim, disbursement, show_assessed: false)).to eq({
            claimed_total_exc_vat: 5.54,
            claimed_total_inc_vat: 5.54,
            claimed_vat: 0.0,
            claimed_vatable: 0.0,
          })
        end
      end
    end
  end

  describe "#calculate_letter_or_call" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10", vat_registered: true } }
    let(:letter_or_call) { { type: :letter, claimed_items: 10, assessed_items: 8 } }

    context "when showing assessed" do
      it "applies rates correctly" do
        expect(described_class.calculate_letter_or_call(claim, letter_or_call, show_assessed: true)).to eq({
          claimed_total_exc_vat: 40.9,
          claimed_vatable: 40.9,
          assessed_total_exc_vat: 32.72,
          assessed_vatable: 32.72,
        })
      end
    end

    context "when not showing assessed" do
      let(:letter_or_call) { { type: :letter, claimed_items: 10 } }

      it "applies rates correctly" do
        expect(described_class.calculate_letter_or_call(claim, letter_or_call, show_assessed: false)).to eq({
          claimed_total_exc_vat: 40.9,
          claimed_vatable: 40.9,
        })
      end
    end

    context "when not vat registered" do
      let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10", vat_registered: false } }

      it "applies rates correctly" do
        expect(described_class.calculate_letter_or_call(claim, letter_or_call, show_assessed: true)).to eq({
          claimed_total_exc_vat: 40.9,
          claimed_vatable: 0.0,
          assessed_total_exc_vat: 32.72,
          assessed_vatable: 0.0,
        })
      end
    end
  end

  describe "#totals" do
    let(:claim) do
      {
        claim_type: "breach_of_injunction",
        cntp_date: "2024-10-10",
        work_items:,
        disbursements:,
        vat_registered:,
        claimed_letters: 5,
        claimed_calls: 3,
        assessed_letters: 5,
        assessed_calls: 3,
      }
    end

    let(:work_items) do
      [
        {
          claimed_time_spent_in_minutes: 50,
          claimed_work_type: "advocacy",
          claimed_uplift_percentage: 20,
          assessed_time_spent_in_minutes: 25,
          assessed_work_type: "travel",
          assessed_uplift_percentage: 85,
        },
        {
          claimed_time_spent_in_minutes: 133,
          claimed_work_type: "waiting",
          claimed_uplift_percentage: 10,
          assessed_time_spent_in_minutes: 132,
          assessed_work_type: "waiting",
          assessed_uplift_percentage: 0,
        },
      ]
    end

    let(:disbursements) do
      [
        {
          disbursement_type: "car",
          claimed_cost: nil,
          assessed_cost: nil,
          claimed_miles: BigDecimal("12.3"),
          assessed_miles: BigDecimal("12.2"),
          claimed_apply_vat: false,
          assessed_apply_vat: false,
        },
        {
          disbursement_type: "other",
          claimed_cost: BigDecimal("123.85"),
          assessed_cost: BigDecimal("122.85"),
          claimed_miles: nil,
          assessed_miles: nil,
          claimed_apply_vat: true,
          assessed_apply_vat: true,
        },
      ]
    end

    context "when showing assessed" do
      context "when claim is vat-registered" do
        let(:vat_registered) { true }
        it "applies calculates the totals" do
          expect(described_class.totals(claim, show_assessed: true)).to eq({
            work_types: {
              travel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 25.0,
                assessed_total_exc_vat: 21.28,
                assessed_vatable: 21.28,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              waiting: {
                claimed_time_spent_in_minutes: 133.0,
                claimed_total_exc_vat: 67.3,
                claimed_vatable: 67.3,
                assessed_time_spent_in_minutes: 132.0,
                assessed_total_exc_vat: 60.72,
                assessed_vatable: 60.72,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              attendance_with_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              attendance_without_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              preparation: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              advocacy: {
                claimed_time_spent_in_minutes: 50.0,
                claimed_total_exc_vat: 65.42,
                claimed_vatable: 65.42,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: true,
                cost_summary_group_changes: true,
              },
              total: {
                assessed_time_spent_in_minutes: 157.0,
                assessed_total_exc_vat: 82.0,
                assessed_vatable: 82.0,
                claimed_time_spent_in_minutes: 183.0,
                claimed_total_exc_vat: 132.72,
                claimed_vatable: 132.72,
                type_changes: true,
                cost_summary_group_changes: true,
              },
            },
            cost_summary: {
              profit_costs: {
                claimed_total_exc_vat: 98.14,
                assessed_total_exc_vat: 32.72,
                claimed_vatable: 98.14,
                claimed_vat: 19.63,
                claimed_total_inc_vat: 117.77,
                assessed_vatable: 32.72,
                assessed_vat: 6.54,
                assessed_total_inc_vat: 39.26,
                group_changes: true,
              },
              disbursements: {
                claimed_total_exc_vat: 129.39,
                claimed_vatable: 123.85,
                claimed_vat: 24.77,
                claimed_total_inc_vat: 154.16,
                assessed_total_exc_vat: 128.34,
                assessed_vatable: 122.85,
                assessed_vat: 24.57,
                assessed_total_inc_vat: 152.91,
                group_changes: false,
              },
              travel: {
                claimed_total_exc_vat: 0.0,
                assessed_total_exc_vat: 21.28,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 0.0,
                assessed_vatable: 21.28,
                assessed_vat: 4.26,
                assessed_total_inc_vat: 25.53,
                group_changes: false,
              },
              waiting: {
                claimed_total_exc_vat: 67.3,
                assessed_total_exc_vat: 60.72,
                claimed_vatable: 67.3,
                claimed_vat: 13.46,
                claimed_total_inc_vat: 80.76,
                assessed_vatable: 60.72,
                assessed_vat: 12.14,
                assessed_total_inc_vat: 72.86,
                group_changes: false,
              },
            },
            totals: {
              claimed_total_exc_vat: 294.82,
              claimed_vatable: 289.29,
              assessed_total_exc_vat: 243.06,
              assessed_vatable: 237.57,
              claimed_vat: 57.86,
              assessed_vat: 47.51,
              claimed_total_inc_vat: 352.68,
              assessed_total_inc_vat: 290.57,
            },
          })
        end
      end

      context "when claim is not vat-registered" do
        let(:vat_registered) { false }

        it "applies calculates the totals" do
          expect(described_class.totals(claim, show_assessed: true)).to eq({
            work_types: {
              travel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 25.0,
                assessed_total_exc_vat: 21.28,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              waiting: {
                claimed_time_spent_in_minutes: 133.0,
                claimed_total_exc_vat: 67.3,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 132.0,
                assessed_total_exc_vat: 60.72,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              attendance_with_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              attendance_without_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              preparation: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: false,
                cost_summary_group_changes: false,
              },
              advocacy: {
                claimed_time_spent_in_minutes: 50.0,
                claimed_total_exc_vat: 65.42,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                type_changes: true,
                cost_summary_group_changes: true,
              },
              total: {
                assessed_time_spent_in_minutes: 157.0,
                assessed_total_exc_vat: 82.0,
                assessed_vatable: 0.0,
                claimed_time_spent_in_minutes: 183.0,
                claimed_total_exc_vat: 132.72,
                claimed_vatable: 0.0,
                type_changes: true,
                cost_summary_group_changes: true,
              },
            },
            cost_summary: {
              profit_costs: {
                claimed_total_exc_vat: 98.14,
                assessed_total_exc_vat: 32.72,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 98.14,
                assessed_vatable: 0.0,
                assessed_vat: 0.0,
                assessed_total_inc_vat: 32.72,
                group_changes: true,
              },
              disbursements: {
                claimed_total_exc_vat: 129.39,
                claimed_vatable: 123.85,
                claimed_vat: 24.77,
                claimed_total_inc_vat: 154.16,
                assessed_total_exc_vat: 128.34,
                assessed_vatable: 122.85,
                assessed_vat: 24.57,
                assessed_total_inc_vat: 152.91,
                group_changes: false,
              },
              travel: {
                claimed_total_exc_vat: 0.0,
                assessed_total_exc_vat: 21.28,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 0.0,
                assessed_vatable: 0.0,
                assessed_vat: 0.0,
                assessed_total_inc_vat: 21.28,
                group_changes: false,
              },
              waiting: {
                claimed_total_exc_vat: 67.3,
                assessed_total_exc_vat: 60.72,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 67.3,
                assessed_vatable: 0.0,
                assessed_vat: 0.0,
                assessed_total_inc_vat: 60.72,
                group_changes: false,
              },
            },
            totals: {
              claimed_total_exc_vat: 294.82,
              claimed_vatable: 123.85,
              assessed_total_exc_vat: 243.06,
              assessed_vatable: 122.85,
              claimed_vat: 24.77,
              assessed_vat: 24.57,
              claimed_total_inc_vat: 319.59,
              assessed_total_inc_vat: 267.63,
            },
          })
        end
      end
    end

    context "when not showing assessed" do
      let(:vat_registered) { true }

      it "applies calculates the totals" do
        expect(described_class.totals(claim, show_assessed: false)).to eq({
          work_types: {
            travel: {
              claimed_time_spent_in_minutes: 0.0,
              claimed_total_exc_vat: 0.0,
              claimed_vatable: 0.0,
            },
            waiting: {
              claimed_time_spent_in_minutes: 133.0,
              claimed_total_exc_vat: 67.3,
              claimed_vatable: 67.3,
            },
            attendance_with_counsel: {
              claimed_time_spent_in_minutes: 0.0,
              claimed_total_exc_vat: 0.0,
              claimed_vatable: 0.0,
            },
            attendance_without_counsel: {
              claimed_time_spent_in_minutes: 0.0,
              claimed_total_exc_vat: 0.0,
              claimed_vatable: 0.0,
            },
            preparation: {
              claimed_time_spent_in_minutes: 0.0,
              claimed_total_exc_vat: 0.0,
              claimed_vatable: 0.0,
            },
            advocacy: {
              claimed_time_spent_in_minutes: 50.0,
              claimed_total_exc_vat: 65.42,
              claimed_vatable: 65.42,
            },
            total: {
              claimed_time_spent_in_minutes: 183.0,
              claimed_total_exc_vat: 132.72,
              claimed_vatable: 132.72,
            },
          },
          cost_summary: {
            profit_costs: {
              claimed_total_exc_vat: 98.14,
              claimed_vatable: 98.14,
              claimed_vat: 19.63,
              claimed_total_inc_vat: 117.77,
            },
            disbursements: {
              claimed_total_exc_vat: 129.39,
              claimed_vatable: 123.85,
              claimed_vat: 24.77,
              claimed_total_inc_vat: 154.16,
            },
            travel: {
              claimed_total_exc_vat: 0.0,
              claimed_vatable: 0.0,
              claimed_vat: 0.0,
              claimed_total_inc_vat: 0.0,
            },
            waiting: {
              claimed_total_exc_vat: 67.3,
              claimed_vatable: 67.3,
              claimed_vat: 13.46,
              claimed_total_inc_vat: 80.76,
            },
          },
          totals: {
            claimed_total_exc_vat: 294.82,
            claimed_vatable: 289.29,
            claimed_vat: 57.86,
            claimed_total_inc_vat: 352.68,
          },
        })
      end
    end
  end
end
