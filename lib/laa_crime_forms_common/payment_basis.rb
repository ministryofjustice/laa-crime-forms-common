module LaaCrimeFormsCommon
  module PaymentBasis
    extend self

    DIGITAL_CLAIM = "digital_claim".freeze
    EXISTING_PAYMENT_RECORD = "existing_payment_record".freeze
    LINKED_NO_ORIGINAL_PAYMENT = "linked_no_original_payment".freeze
    NEW_UNLINKED_RECORD = "new_unlinked_record".freeze
    STANDARD_MANUAL_ENTRY = "standard_manual_entry".freeze

    ENTERED_TO_BE_PAID = "entered_to_be_paid".freeze
    CALCULATED_DIFFERENCE = "calculated_difference".freeze

    CALCULATION_METHOD_BY_BASIS = {
      DIGITAL_CLAIM => ENTERED_TO_BE_PAID,
      EXISTING_PAYMENT_RECORD => CALCULATED_DIFFERENCE,
      LINKED_NO_ORIGINAL_PAYMENT => ENTERED_TO_BE_PAID,
      NEW_UNLINKED_RECORD => ENTERED_TO_BE_PAID,
      STANDARD_MANUAL_ENTRY => ENTERED_TO_BE_PAID,
    }.freeze

    ALL = CALCULATION_METHOD_BY_BASIS.keys.freeze

    def valid_basis?(value)
      ALL.include?(normalize(value))
    end

    def calculation_method_for(value)
      CALCULATION_METHOD_BY_BASIS[normalize(value)]
    end

  private

    def normalize(value)
      value.to_s
    end
  end
end
