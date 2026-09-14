module LaaCrimeFormsCommon
  module PaymentFamily
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
        "nsm_claim"
      when "AssignedCounselClaim"
        "assigned_counsel_claim"
      else
        raise StandardError, "request type '#{request_type}' is not recognized"
      end
    end

    def linked_payment?(request_type)
      request_type.in?(
        %w[
          non_standard_mag_supplemental
          non_standard_mag_amendment
          non_standard_mag_appeal
          assigned_counsel_appeal
          assigned_counsel_amendment
        ],
      )
    end
  end
end
