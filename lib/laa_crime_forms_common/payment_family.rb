module LaaCrimeFormsCommon
  module PaymentFamily
  module_function

    CLAIM_TYPE_MAP = {
      "NsmClaim" => %w[
        breach_of_injunction
        non_standard_magistrate
        non_standard_mag_supplemental
        non_standard_mag_appeal
        non_standard_mag_amendment
      ],
      "AssignedCounselClaim" => %w[
        assigned_counsel
        assigned_counsel_appeal
        assigned_counsel_amendment
      ],
    }.freeze

    def find_claim_type_group(request_type)
      CLAIM_TYPE_MAP.find { |_, types| types.include?(request_type) }&.first
    end

    def get_claim_type_marker(request_type)
      case find_claim_type_group(request_type)
      when "NsmClaim"
        "non_standard_magistrate"
      when "AssignedCounselClaim"
        "assigned_counsel"
      else
        raise StandardError, "request type '#{request_type}' is not recognized"
      end
    end
  end
end
