require "date"

module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        class Bool
          def self.call(bool)
            return bool if [true, false].include?(bool)

            raise "Cannot cast #{bool.class} to true or false"
          end
        end
      end
    end
  end
end
