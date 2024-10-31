module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        # This is a convenience class that allows us to wrap a hash, confirming
        # that is has the right value of the right type.
        class Base
          def initialize(hash_to_wrap)
            @wrapped_hash = hash_to_wrap
          end

          def self.wrap(attribute, type, options = {})
            define_method(attribute) do
              raw_value = if @wrapped_hash.key?(attribute)
                            @wrapped_hash[attribute]
                          elsif @wrapped_hash.key?(attribute.to_s)
                            @wrapped_hash[attribute.to_s]
                          else
                            raise "#{@wrapped_hash.class} does not have '#{attribute}' attribute"
                          end
              if raw_value.nil? && options.key?(:default)
                options[:default]
              elsif raw_value.nil?
                raise "'#{attribute}' in #{self.class} is nil, but must not be"
              elsif raw_value.is_a?(type)
                raw_value
              elsif type.respond_to?(:call)
                type.call(raw_value)
              else
                type.new(raw_value)
              end
            end
          end
        end
      end
    end
  end
end
