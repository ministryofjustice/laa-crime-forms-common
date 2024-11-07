require "date"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class DateOrDateString
          def self.call(string_or_date)
            if string_or_date.is_a?(String)
              Date.new(*string_or_date.split("-").map(&:to_i))
            elsif string_or_date.is_a?(Date)
              string_or_date
            else
              raise "Cannot cast #{string_or_date.class} to Date"
            end
          end
        end
      end
    end
  end
end
