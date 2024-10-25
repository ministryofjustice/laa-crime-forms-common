module LaaCrimeFormsCommon
  module Pricing
    module Nsm
      module Wrappers
        # This is a convenience class that allows us to wrap either an object or a hash, confirming
        # that is has the right value of the right type.
        class Base
          def initialize(object_to_wrap)
            @wrapped_object = object_to_wrap
          end

          def self.wrap(attribute, type, options = {})
            define_method(attribute) do
              raw_value = if @wrapped_object.respond_to?(attribute)
                            @wrapped_object.public_send(attribute)
                          elsif @wrapped_object.respond_to?(:key?) && @wrapped_object.key?(attribute)
                            @wrapped_object[attribute]
                          elsif @wrapped_object.respond_to?(:key?) && @wrapped_object.key?(attribute.to_s)
                            @wrapped_object[attribute.to_s]
                          else
                            raise "#{@wrapped_object.class} does not have '#{attribute}' attribute"
                          end
              if raw_value.nil? && options.key?(:default)
                options[:default]
              elsif raw_value.nil?
                raise "'#{attribute}' in #{@wrapped_object.class} is nil, but must not be"
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
