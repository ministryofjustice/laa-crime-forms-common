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
        expect(described_class.calculate_work_item(claim, work_item)).to eq({
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
          claimed_time_spent_in_minutes: nil,
          claimed_work_type: "advocacy",
          claimed_uplift_percentage: 10,
          assessed_time_spent_in_minutes: 25,
          assessed_work_type: "travel",
          assessed_uplift_percentage: 85,
        }

        expect { described_class.calculate_work_item(claim, work_item) }.to raise_error(
          "'claimed_time_spent_in_minutes' in LaaCrimeFormsCommon::Pricing::Nsm::Wrappers::WorkItem is nil, but must not be",
        )
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
        expect(described_class.calculate_disbursement(claim, disbursement)).to eq({
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
        expect(described_class.calculate_disbursement(claim, disbursement)).to eq({
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
    end
  end

  describe "#calculate_letter_or_call" do
    let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10", vat_registered: true } }
    let(:letter_or_call) { { type: :letters, claimed_items: 10, assessed_items: 8, claimed_uplift_percentage: 20, assessed_uplift_percentage: 0 } }

    context "when showing assessed" do
      it "applies rates correctly" do
        expect(described_class.calculate_letter_or_call(claim, letter_or_call)).to eq({
          claimed_subtotal_without_uplift: 40.9,
          claimed_total_exc_vat: 49.08,
          claimed_vatable: 49.08,
          assessed_subtotal_without_uplift: 32.72,
          assessed_total_exc_vat: 32.72,
          assessed_vatable: 32.72,
        })
      end
    end

    context "when not vat registered" do
      let(:claim) { { claim_type: "breach_of_injunction", cntp_date: "2024-10-10", vat_registered: false } }

      it "applies rates correctly" do
        expect(described_class.calculate_letter_or_call(claim, letter_or_call)).to eq({
          claimed_subtotal_without_uplift: 40.9,
          claimed_vatable: 0.0,
          claimed_total_exc_vat: 49.08,
          assessed_subtotal_without_uplift: 32.72,
          assessed_total_exc_vat: 32.72,
          assessed_vatable: 0.0,
        })
      end
    end
  end

  describe "#youth_court_fee" do
    let(:claim) do
      {
        claim_type:,
        rep_order_date: claim_date,
        vat_registered: true,
        claimed_youth_court_fee_included:,
        assessed_youth_court_fee_included:,
        youth_court:,
        plea_category:,
      }
    end
    let(:claim_type) { "non_standard_magistrate" }
    let(:claim_date) { "2024-10-10" }
    let(:vat_registered) { true }
    let(:claimed_youth_court_fee_included) { true }
    let(:assessed_youth_court_fee_included) { nil }
    let(:youth_court) { true }
    let(:plea_category) { "category_1a" }

    context "claim date pre december 6th (Non-standard magistrate)" do
      it "does not apply the fee" do
        expect(described_class.calculate_youth_court_fee(claim)).to eq({
          claimed_total_exc_vat: 0.0,
          assessed_total_exc_vat: 0.0,
          claimed_vatable: 0.0,
          assessed_vatable: 0.0,
        })
      end
    end

    context "claim date on december 6th (Breach of inunction)" do
      let(:claim_type) { "breach_of_injunction" }
      let(:claim_date) { "2024-12-06" }
      let(:claim) do
        {
          claim_type:,
          cntp_date: claim_date,
          vat_registered: true,
          claimed_youth_court_fee_included:,
          assessed_youth_court_fee_included:,
          youth_court:,
          plea_category:,
        }
      end

      it "it does not apply the fee" do
        expect(described_class.calculate_youth_court_fee(claim)).to eq({
          claimed_total_exc_vat: 0.0,
          assessed_total_exc_vat: 0.0,
          claimed_vatable: 0.0,
          assessed_vatable: 0.0,
        })
      end
    end

    context "claim date december 6th and onwards" do
      let(:claim_date) { "2024-12-06" }

      context "youth court fee not claimed" do
        let(:claimed_youth_court_fee_included) { false }

        it "does not apply the fee" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 0.0,
            assessed_total_exc_vat: 0.0,
            claimed_vatable: 0.0,
            assessed_vatable: 0.0,
          })
        end
      end

      context "hearing not in youth court" do
        let(:youth_court) { false }

        it "does not apply the fee" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 0.0,
            assessed_total_exc_vat: 0.0,
            claimed_vatable: 0.0,
            assessed_vatable: 0.0,
          })
        end
      end

      context "plea category not applicable to fee" do
        let(:plea_category) { "category_1b" }

        it "does not apply the fee" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 0.0,
            assessed_total_exc_vat: 0.0,
            claimed_vatable: 0.0,
            assessed_vatable: 0.0,
          })
        end
      end

      context "youth court fee applicable and claimed" do
        it "applies the fee" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 598.59,
            assessed_total_exc_vat: 0.0,
            claimed_vatable: 598.59,
            assessed_vatable: 0.0,
          })
        end
      end

      context "youth court fee applicable, claimed and granted" do
        let(:assessed_youth_court_fee_included) { true }

        it "applies the fee" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 598.59,
            assessed_total_exc_vat: 598.59,
            claimed_vatable: 598.59,
            assessed_vatable: 598.59,
          })
        end
      end

      context "youth court fee applicable, claimed and rejected" do
        let(:assessed_youth_court_fee_included) { false }

        it "shows the original claim but does not apply the fee in assessed values" do
          expect(described_class.calculate_youth_court_fee(claim)).to eq({
            claimed_total_exc_vat: 598.59,
            assessed_total_exc_vat: 0.0,
            claimed_vatable: 598.59,
            assessed_vatable: 0.0,
          })
        end
      end
    end
  end

  describe "#totals" do
    let(:claimed_youth_court_fee_included) { true }
    let(:assessed_youth_court_fee_included) { true }
    let(:youth_court) { true }
    let(:plea_category) { "category_1a" }
    let(:claim) do
      {
        claim_type: "non_standard_magistrate",
        rep_order_date: "2024-12-06",
        claimed_youth_court_fee_included:,
        assessed_youth_court_fee_included:,
        youth_court:,
        plea_category:,
        work_items:,
        disbursements:,
        vat_registered:,
        letters_and_calls:,
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

    let(:letters_and_calls) do
      [
        {
          type: :letters,
          claimed_items: 5,
          claimed_uplift_percentage: 50,
          assessed_items: 5,
          assessed_uplift_percentage: 40,
        },
        {
          type: :calls,
          claimed_items: 3,
          claimed_uplift_percentage: 30,
          assessed_items: 2,
          assessed_uplift_percentage: 20,
        },
      ]
    end

    context "when showing assessed" do
      context "when claim is vat-registered" do
        let(:vat_registered) { true }
        it "applies calculates the totals" do
          expect(described_class.totals(claim)).to eq({
            work_types: {
              travel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 25.0,
                assessed_total_exc_vat: 21.28,
                assessed_vatable: 21.28,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              waiting: {
                claimed_time_spent_in_minutes: 133.0,
                claimed_total_exc_vat: 67.3,
                claimed_vatable: 67.3,
                assessed_time_spent_in_minutes: 132.0,
                assessed_total_exc_vat: 60.72,
                assessed_vatable: 60.72,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              attendance_with_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              attendance_without_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              preparation: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              advocacy: {
                claimed_time_spent_in_minutes: 50.0,
                claimed_total_exc_vat: 65.42,
                claimed_vatable: 65.42,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: true,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
              },
              total: {
                assessed_time_spent_in_minutes: 157.0,
                assessed_total_exc_vat: 82.0,
                assessed_total_inc_vat: 98.4,
                assessed_vat: 16.4,
                assessed_vatable: 82.0,
                claimed_time_spent_in_minutes: 183.0,
                claimed_total_exc_vat: 132.72,
                claimed_total_inc_vat: 159.26,
                claimed_vat: 26.54,
                claimed_vatable: 132.72,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
                at_least_one_claimed_work_item_assessed_as_different_type: true,
              },
            },
            letters_and_calls: {
              assessed_total_exc_vat: 38.45,
              assessed_total_inc_vat: 46.14,
              assessed_vat: 7.69,
              assessed_vatable: 38.45,
              claimed_total_exc_vat: 46.63,
              claimed_total_inc_vat: 55.95,
              claimed_vat: 9.33,
              claimed_vatable: 46.63,
            },
            additional_fees: {
              youth_court_fee: {
                claimed_total_exc_vat: 598.59,
                assessed_total_exc_vat: 598.59,
                claimed_vatable: 598.59,
                claimed_vat: 119.72,
                claimed_total_inc_vat: 718.31,
                assessed_vatable: 598.59,
                assessed_vat: 119.72,
                assessed_total_inc_vat: 718.31,
              },
              total: {
                claimed_total_exc_vat: 598.59,
                assessed_total_exc_vat: 598.59,
                claimed_vatable: 598.59,
                claimed_vat: 119.72,
                claimed_total_inc_vat: 718.31,
                assessed_vatable: 598.59,
                assessed_vat: 119.72,
                assessed_total_inc_vat: 718.31,
              },
            },
            cost_summary: {
              profit_costs: {
                claimed_total_exc_vat: 710.64,
                assessed_total_exc_vat: 637.04,
                claimed_vatable: 710.64,
                claimed_vat: 142.13,
                claimed_total_inc_vat: 852.76,
                assessed_vatable: 637.04,
                assessed_vat: 127.41,
                assessed_total_inc_vat: 764.44,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
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
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              travel: {
                claimed_total_exc_vat: 0.0,
                assessed_total_exc_vat: 21.28,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 0.0,
                assessed_vatable: 21.28,
                assessed_vat: 4.26,
                assessed_total_inc_vat: 25.54,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
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
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
            },
            totals: {
              claimed_total_exc_vat: 907.32,
              claimed_vatable: 901.79,
              assessed_total_exc_vat: 847.38,
              assessed_vatable: 841.89,
              claimed_vat: 180.36,
              assessed_vat: 168.38,
              claimed_total_inc_vat: 1087.68,
              assessed_total_inc_vat: 1015.75,
            },
          })
        end
      end

      context "when claim is not vat-registered" do
        let(:vat_registered) { false }

        it "applies calculates the totals" do
          expect(described_class.totals(claim)).to eq({
            work_types: {
              travel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 25.0,
                assessed_total_exc_vat: 21.28,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              waiting: {
                claimed_time_spent_in_minutes: 133.0,
                claimed_total_exc_vat: 67.3,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 132.0,
                assessed_total_exc_vat: 60.72,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              attendance_with_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              attendance_without_counsel: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              preparation: {
                claimed_time_spent_in_minutes: 0.0,
                claimed_total_exc_vat: 0.0,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: false,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
              advocacy: {
                claimed_time_spent_in_minutes: 50.0,
                claimed_total_exc_vat: 65.42,
                claimed_vatable: 0.0,
                assessed_time_spent_in_minutes: 0.0,
                assessed_total_exc_vat: 0.0,
                assessed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_different_type: true,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
              },
              total: {
                assessed_time_spent_in_minutes: 157.0,
                assessed_total_exc_vat: 82.0,
                assessed_total_inc_vat: 82.0,
                assessed_vat: 0.0,
                assessed_vatable: 0.0,
                claimed_time_spent_in_minutes: 183.0,
                claimed_total_exc_vat: 132.72,
                claimed_total_inc_vat: 132.72,
                claimed_vat: 0.0,
                claimed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
                at_least_one_claimed_work_item_assessed_as_different_type: true,
              },
            },
            letters_and_calls: {
              assessed_total_exc_vat: 38.45,
              assessed_total_inc_vat: 38.45,
              assessed_vat: 0.0,
              assessed_vatable: 0.0,
              claimed_total_exc_vat: 46.63,
              claimed_total_inc_vat: 46.63,
              claimed_vat: 0.0,
              claimed_vatable: 0.0,
            },
            additional_fees: {
              youth_court_fee: {
                claimed_total_exc_vat: 598.59,
                assessed_total_exc_vat: 598.59,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 598.59,
                assessed_vatable: 0.0,
                assessed_vat: 0.0,
                assessed_total_inc_vat: 598.59,
              },
              total: {
                claimed_total_exc_vat: 598.59,
                assessed_total_exc_vat: 598.59,
                claimed_vatable: 0.0,
                claimed_vat: 0.0,
                claimed_total_inc_vat: 598.59,
                assessed_vatable: 0.0,
                assessed_vat: 0.0,
                assessed_total_inc_vat: 598.59,
              },
            },
            cost_summary: {
              profit_costs: {
                assessed_total_exc_vat: 637.04,
                assessed_total_inc_vat: 637.04,
                assessed_vat: 0.0,
                assessed_vatable: 0.0,
                claimed_total_exc_vat: 710.64,
                claimed_total_inc_vat: 710.64,
                claimed_vat: 0.0,
                claimed_vatable: 0.0,
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: true,
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
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
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
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
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
                at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group: false,
              },
            },
            totals: {
              assessed_total_exc_vat: 847.38,
              assessed_total_inc_vat: 871.95,
              assessed_vat: 24.57,
              assessed_vatable: 122.85,
              claimed_total_exc_vat: 907.32,
              claimed_total_inc_vat: 932.09,
              claimed_vat: 24.77,
              claimed_vatable: 123.85,
            },
          })
        end
      end

      context "rounds work_types summary costs totals" do
        let(:vat_registered) { false }

        let(:disbursements) { [] }
        let(:letters_and_calls) { [] }
        let(:assessed_youth_court_fee_included) { false }
        let(:claimed_youth_court_fee_included) { false }
        let(:work_items) do
          [
            {
              claimed_time_spent_in_minutes: 426,
              claimed_work_type: "advocacy",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 426,
              assessed_work_type: "advocacy",
              assessed_uplift_percentage: 0,
            },
            {
              claimed_time_spent_in_minutes: 426,
              claimed_work_type: "preparation",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 426,
              assessed_work_type: "preparation",
              assessed_uplift_percentage: 0,
            },
            {
              claimed_time_spent_in_minutes: 426,
              claimed_work_type: "attendance_without_counsel",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 426,
              assessed_work_type: "attendance_without_counsel",
              assessed_uplift_percentage: 0,
            },
          ]
        end

        it "applies calculates the expected work_items totals" do
          expect(described_class.totals(claim)[:work_types][:total][:claimed_total_inc_vat]).to eq(1205.02)
        end
      end

      context "rounds claim summary net costs partial totals" do
        let(:vat_registered) { false }

        let(:disbursements) do
          [
            {
              disbursement_type: "car",
              claimed_cost: BigDecimal("20.48"),
              assessed_cost: BigDecimal("20.48"),
              claimed_miles: BigDecimal("45.5"),
              assessed_miles: BigDecimal("45.5"),
              claimed_apply_vat: false,
              assessed_apply_vat: false,
            },
            {
              disbursement_type: "other",
              claimed_cost: BigDecimal("350.00"),
              assessed_cost: BigDecimal("350.00"),
              claimed_miles: nil,
              assessed_miles: nil,
              claimed_apply_vat: false,
              assessed_apply_vat: false,
            },
            {
              disbursement_type: "other",
              claimed_cost: BigDecimal("350.00"),
              assessed_cost: BigDecimal("350.00"),
              claimed_miles: nil,
              assessed_miles: nil,
              claimed_apply_vat: false,
              assessed_apply_vat: false,
            },
          ]
        end
        let(:letters_and_calls) do
          [
            { type: :letters,
              claimed_items: 10,
              assessed_items: 10,
              claimed_uplift_percentage: 5,
              assessed_uplift_percentage: 5 },
            { type: :calls,
              claimed_items: 10,
              assessed_items: 10,
              claimed_uplift_percentage: 0,
              assessed_uplift_percentage: 0 },
          ]
        end

        let(:assessed_youth_court_fee_included) { false }
        let(:claimed_youth_court_fee_included) { false }
        let(:work_items) do
          [
            {
              claimed_time_spent_in_minutes: 90,
              claimed_work_type: "travel",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 90,
              assessed_work_type: "travel",
              assessed_uplift_percentage: 0,
            },
            {
              claimed_time_spent_in_minutes: 120,
              claimed_work_type: "preparation",
              claimed_uplift_percentage: 100,
              assessed_time_spent_in_minutes: 120,
              assessed_work_type: "preparation",
              assessed_uplift_percentage: 100,
            },
            {
              claimed_time_spent_in_minutes: 120,
              claimed_work_type: "preparation",
              claimed_uplift_percentage: 20,
              assessed_time_spent_in_minutes: 120,
              assessed_work_type: "preparation",
              assessed_uplift_percentage: 20,
            },
            {
              claimed_time_spent_in_minutes: 60,
              claimed_work_type: "attendance_without_counsel",
              claimed_uplift_percentage: 0,
              assessed_time_spent_in_minutes: 60,
              assessed_work_type: "attendance_without_counsel",
              assessed_uplift_percentage: 0,
            },
          ]
        end

        it "applies calculates the expected work_items totals" do
          expect(described_class.totals(claim)[:totals][:claimed_total_exc_vat]).to eq(1231.63)
        end
      end
    end
  end
end
