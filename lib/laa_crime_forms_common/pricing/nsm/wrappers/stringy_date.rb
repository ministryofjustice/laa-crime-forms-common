require "date"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class StringyDate < Date
          def initialize(string_or_date)
            if string_or_date.is_a?(String)
              super(*string_or_date.split("-").map(&:to_i))
            else
              super string_or_date.year, string_or_date.month, string_or_date.day
            end
          end
        end
      end
    end
  end
end
