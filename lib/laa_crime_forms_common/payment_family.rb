module LaaCrimeFormsCommon
  module PaymentHelper
    def get_parent(request_type)
      if request_type.start_with?("non_standard_mag")
        "non_standard_magistrate"
      elsif request_type.start_with?("assigned_counsel")
        "assigned_counsel"
      else
        raise "Unknown request type"
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
