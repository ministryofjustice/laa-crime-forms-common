require "bigdecimal"
require_relative "location_service"

module LaaCrimeFormsCommon
  module Autogrant
    class PriorAuthority
      def self.autograntable?(data, sql_executor)
        new(data, sql_executor).autograntable?
      rescue LaaCrimeFormsCommon::Autogrant::LocationService::NotFoundError,
             LaaCrimeFormsCommon::Autogrant::LocationService::UnknowablePartialPostcode,
             LaaCrimeFormsCommon::Autogrant::LocationService::LocationError
        false
      end

      attr_reader :reason

      def initialize(data, sql_executor)
        @data = data
        @sql_executor = sql_executor
      end

      def autograntable?
        return fail_with_reason(:additional_costs) if any_additional_costs?
        return fail_with_reason(:unknown_service) unless limits
        return fail_with_reason(:exceed_service_costs) unless below_service_cost_limit?
        return fail_with_reason(:exceed_travel_costs) unless below_travel_cost_limit?

        true
      end

      def below_service_cost_limit?
        if quote["cost_type"] == "per_hour"
          (limits["max_units"] * 60) >= quote["period"].to_i && BigDecimal(max_rate) >= BigDecimal(quote["cost_per_hour"])
        else
          limits["max_units"] >= quote["items"] && BigDecimal(max_rate) >= BigDecimal(quote["cost_per_item"])
        end
      end

      def fail_with_reason(reason)
        @reason = reason
        false
      end

      def below_travel_cost_limit?
        return true if quote["travel_time"].to_i.zero?

        (limits["travel_hours"] * 60) >= quote["travel_time"].to_i && BigDecimal(max_travel_rate) >= BigDecimal(quote["travel_cost_per_hour"])
      end

      def max_travel_rate
        london? ? limits["travel_rate_london"] : limits["travel_rate_non_london"]
      end

      def max_rate
        london? ? limits["max_rate_london"] : limits["max_rate_non_london"]
      end

      def london?
        LaaCrimeFormsCommon::Autogrant::LocationService.inside_m25?(quote["postcode"], @sql_executor)
      end

      def limits
        @limits ||= JSON.load_file(File.join(__dir__, "grant_limits.json"))
                        .sort_by { Date.parse(_1["start_date"]) }
                        .reverse
                        .find do |limit|
          limit["service"] == service &&
            Date.parse(limit["start_date"]) < start_date &&
            limit["unit_type"] == quote["cost_type"]
        end
      end

      def quote
        @quote ||= @data["quotes"].find { _1["primary"] }
      end

    private

      def any_additional_costs?
        @data["additional_costs"]&.any?
      end

      def service
        @data["service_type"]
      end

      def start_date
        if @data["prison_law"]
          _, day, month, year = *@data["ufn"].match(%r{\A(\d{2})(\d{2})(\d{2})/})
          Date.new(2000 + year.to_i, month.to_i, day.to_i)
        else
          Date.parse(@data["rep_order_date"])
        end
      end
    end
  end
end
