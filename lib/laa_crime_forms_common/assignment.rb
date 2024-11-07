module LaaCrimeFormsCommon
  module Assignment
    extend self

    def build_assignment_query(base_query, application_type, options)
      case application_type
      when "crm4"
        build_pa_assignment_query(base_query,
                                  options.fetch(:fields_to_select),
                                  options.fetch(:updated_at_column),
                                  options.fetch(:data_column),
                                  options.fetch(:sanitizer))
      when "crm7"
        build_nsm_assignment_query(base_query,
                                   options.fetch(:updated_at_column),
                                   options.fetch(:data_column),
                                   options.fetch(:risk_column))
      else
        raise "Unknown application type '#{application_type}'"
      end
    end

  private

    def build_pa_assignment_query(query, fields_to_select, updated_at_column, data_column, sanitizer)
      pathologist_report_relating_to_post_mortem = <<~SQL
        CASE
        WHEN (#{data_column}->>'service_type' = 'pathologist_report')
          AND EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(#{data_column}->'quotes') AS quotes WHERE quotes.value->>'related_to_post_mortem' = 'true'
          ) THEN 0
        ELSE 1
        END as post_mortem_pathologist_report
      SQL

      criminal_court = "CASE WHEN #{data_column}->>'court_type' = 'central_criminal_court' THEN 0 ELSE 1 END as criminal_court"
      date_order_clause = sanitizer.sql("DATE_TRUNC('day', #{updated_at_column}) ASC")

      query.select(fields_to_select,
                   criminal_court,
                   sanitizer.sql(pathologist_report_relating_to_post_mortem))
           .order(
             date_order_clause,
             criminal_court: :asc,
             post_mortem_pathologist_report: :asc,
             updated_at_column => :asc,
           )
    end

    def build_nsm_assignment_query(query, updated_at_column, data_column, risk_column)
      high_value_threshold = 5000
      query.where("(#{data_column}->'cost_summary'->'high_value' IS NOT NULL AND NOT (#{data_column}->'cost_summary'->'high_value')::boolean) OR " \
                  "(#{data_column}->'cost_summary'->'high_value' IS NULL AND #{data_column}->'cost_summary' IS NOT NULL AND " \
                  "(#{data_column}->'cost_summary'->'profit_costs'->>'gross_cost')::decimal < ?) OR " \
                  "(#{data_column}->'cost_summary' IS NULL AND #{risk_column} != 'high')",
                  high_value_threshold)
           .order(updated_at_column => :asc)
    end
  end
end
