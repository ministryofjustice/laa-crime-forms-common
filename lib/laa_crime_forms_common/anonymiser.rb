require "json"
require_relative "validator"

module LaaCrimeFormsCommon
  class Anonymiser
    class << self
      def anonymise(service_type, payload, version: 1)
        schema = JSON.parse(File.read(Validator.schema_file(service_type, version:)))
        recursively_anonymise(payload, schema)
      end

    private

      def recursively_anonymise(payload, schema)
        case payload
        when Array
          payload.map do |element|
            recursively_anonymise(element, schema["items"])
          end
        when Hash
          mapped = payload.map do |key, value|
            [key, recursively_anonymise(value, schema["properties"][key])]
          end
          mapped.to_h
        else
          if schema["x-pii"]
            "ANONYMISED" if payload
          else
            payload
          end
        end
      end
    end
  end
end
