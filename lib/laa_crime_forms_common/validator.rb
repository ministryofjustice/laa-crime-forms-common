module LaaCrimeFormsCommon
  class Validator
    MAX_VERSION = 1

    class << self
      def validate(service_type, payload, version: 1)
        raise "Unknown service type" unless %i[prior_authority nsm].include?(service_type)
        raise "Unknown version" unless (1..MAX_VERSION).include?(version)

        JSON::Validator.fully_validate(File.join(__dir__, "../schemas/#{service_type}/v#{version}.json"),
                                       payload.to_json)
      end
    end
  end
end
