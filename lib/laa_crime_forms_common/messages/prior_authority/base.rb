require "bigdecimal"

module LaaCrimeFormsCommon
  module Messages
    module PriorAuthority
      class Base
        def initialize(data)
          @data = data
        end

        def template
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def contents
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def recipient
          @data["solicitor"]["contact_email"]
        end

      protected

        def defendant
          @data["defendant"]
        end

        def defendant_name
          "#{defendant['first_name']} #{defendant['last_name']}"
        end

        def case_reference
          @data["laa_reference"]
        end

        def ufn
          @data["ufn"]
        end

        def application_total
          as_money(base_cost(original: true) + travel_costs(original: true) + additional_costs(original: true))
        end

        def adjusted_total
          as_money(base_cost(original: false) + travel_costs(original: false) + additional_costs(original: false))
        end

        def as_money(decimal)
          "£#{sprintf('%.2f', decimal.round(2))}"
        end

        def comments
          @data["assessment_comment"]
        end

        def service_required
          if @data["service_type"] == "custom"
            @data["custom_service_name"]
          else
            I18n.t("laa_crime_forms_common.prior_authority.service_types.#{@data['service_type']}")
          end
        end

        def service_provider_details
          full_name = "#{quote['contact_first_name']} #{quote['contact_last_name']}"
          [full_name, quote["organisation"], quote["town"], quote["postcode"]].compact.join(", ")
        end

        def quote
          @quote ||= @data["quotes"].find { _1["primary"] }
        end

        def base_cost(original:)
          if quote["cost_type"] == "per_item"
            total_item_cost(original:)
          else
            period_to_consider = quote_attribute("period", original:)
            hourly_cost = BigDecimal(quote_attribute("cost_per_hour", original:))
            (period_to_consider * hourly_cost / 60.0).round(2)
          end
        end

        def total_item_cost(original:)
          quote_attribute("items", original:) *
            BigDecimal(quote_attribute("cost_per_item", original:)) *
            BigDecimal(quote_attribute("cost_multiplier", original:))
        end

        def original_total_item_cost
          original_items * BigDecimal(original_cost_per_item) * BigDecimal(cost_multiplier)
        end

        def quote_attribute(key, original:)
          cost_attribute(quote, key, original:)
        end

        def cost_attribute(cost, key, original:)
          if original
            cost["#{key}_original"] || cost[key]
          else
            cost[key]
          end
        end

        def travel_costs(original:)
          time = quote_attribute("travel_time", original:)
          hourly_cost = quote_attribute("travel_cost_per_hour", original:)
          return 0 unless time.to_i.positive? && hourly_cost.to_f.positive?

          (time * BigDecimal(hourly_cost) / 60.0).round(2)
        end

        def additional_costs(original: false)
          @data["additional_costs"].sum do |cost|
            if cost["unit_type"] == "per_item"
              cost_attribute(cost, "items", original:) * BigDecimal(cost_attribute(cost, "cost_per_item", original:))
            else
              period_to_consider = cost_attribute(cost, "period", original:)
              hourly_cost = cost_attribute(cost, "cost_per_hour", original:)
              (period_to_consider * BigDecimal(hourly_cost) / 60.0).round(2)
            end
          end
        end
      end
    end
  end
end
