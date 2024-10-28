require "yaml"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      class Rates
        class << self
          def call(claim)
            date = case claim.claim_type
                   when "non_standard_magistrate"
                     claim.rep_order_date
                   when "breach_of_injunction"
                     claim.cntp_date
                   else
                     raise "Unrecognised claim type '#{claim.claim_type}'"
                   end

            raise "No date set for claim" unless date

            rates = rate_sets.detect do |rate_set|
              range_start = rate_set["from"] && Date.parse(rate_set["from"])
              range_end = rate_set["until"] && Date.parse(rate_set["until"])

              (range_start..range_end).cover?(date)
            end

            new(rates["values"])
          end

          def rate_sets
            @rate_sets ||= YAML.load_file(File.join(__dir__, "rate_sets.yml"))
          end
        end

        FIELDS = %w[
          work_items
          letters_and_calls
          disbursements
          vat
        ].freeze

        attr_reader(*FIELDS)

        def initialize(data)
          FIELDS.each do |field|
            instance_variable_set(:"@#{field}", transform(data[field]))
          end
        end

      private

        def transform(field)
          return BigDecimal(field.to_s) unless field.is_a?(Hash)

          field.transform_keys(&:to_sym).transform_values { BigDecimal(_1.to_s) }
        end
      end
    end
  end
end
