require_relative "../lib/laa_crime_forms_common/assignment"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::Assignment do
  describe ".build_assignment_query" do
    let(:base_query) { double(:query, where: orderable, select: orderable) }
    let(:orderable) { double(:query, order: result) }
    let(:result) { :result }
    let(:fields_to_select) { "FIELDS" }
    let(:updated_at_column) { "UPDATED_AT" }
    let(:data_column) { "DATA" }
    let(:risk_column) { "RISK" }
    let(:sanitizer) { double(:arel, sql: "SANITIZED") }

    subject do
      LaaCrimeFormsCommon::Assignment.build_assignment_query(
        base_query,
        application_type,
        fields_to_select:,
        updated_at_column:,
        data_column:,
        risk_column:,
        sanitizer:,
      )
    end

    context "when PA" do
      let(:application_type) { "crm4" }

      let(:pathologist_clause) do
        <<~SQL
          CASE
          WHEN (DATA->>'service_type' = 'pathologist_report')
            AND EXISTS (
              SELECT 1 FROM JSONB_ARRAY_ELEMENTS(DATA->'quotes') AS quotes WHERE quotes.value->>'related_to_post_mortem' = 'true'
            ) THEN 0
          ELSE 1
          END as post_mortem_pathologist_report
        SQL
      end

      it "returns the ordered query" do
        expect(subject).to eq result
      end

      it "calls the appropriate parts" do
        allow(sanitizer).to receive(:sql).with(pathologist_clause).and_return("SANITIZED-PATHOLOGIST")
        allow(sanitizer).to receive(:sql).with("DATE_TRUNC('day', UPDATED_AT) ASC").and_return("SANITIZED-DAY")

        subject

        expect(base_query).to have_received(:select).with(
          "FIELDS",
          "CASE WHEN DATA->>'court_type' = 'central_criminal_court' THEN 0 ELSE 1 END as criminal_court",
          "SANITIZED-PATHOLOGIST",
        )

        expect(orderable).to have_received(:order).with(
          "SANITIZED-DAY",
          criminal_court: :asc,
          post_mortem_pathologist_report: :asc,
          "UPDATED_AT" => :asc,
        )
      end
    end

    context "when NSM" do
      let(:application_type) { "crm7" }

      it "returns the ordered query" do
        expect(subject).to eq result
      end

      it "calls the appropriate parts" do
        subject

        expect(base_query).to have_received(:where).with(
          "(DATA->'cost_summary'->'high_value' IS NOT NULL AND NOT (DATA->'cost_summary'->'high_value')::boolean) OR " \
          "(DATA->'cost_summary'->'high_value' IS NULL AND DATA->'cost_summary' IS NOT NULL AND " \
          "(DATA->'cost_summary'->'profit_costs'->>'gross_cost')::decimal < ?) OR " \
          "(DATA->'cost_summary' IS NULL AND RISK != 'high')",
          5000,
        )

        expect(orderable).to have_received(:order).with(
          "UPDATED_AT" => :asc,
        )
      end
    end

    context "when other" do
      let(:application_type) { "crm5" }

      it "raises and error" do
        expect { subject }.to raise_error "Unknown application type 'crm5'"
      end
    end
  end
end
