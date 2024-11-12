require_relative "base"

module LaaCrimeFormsCommon
  module Messages
    module PriorAuthority
      class FurtherInformationRequest < Base
        def template
          "c8abf9ee-5cfe-44ab-9253-72111b7a35ba"
        end

        def contents
          {
            laa_case_reference: case_reference,
            ufn:,
            defendant_name:,
            application_total:,
            date_to_respond_by:,
            caseworker_information_requested: comments,
            date: Time.now.strftime("%-d %B %Y"),
          }
        end

      protected

        def comments
          comments = []

          if further_information_explanation.present?
            comments << "## #{I18n.t('laa_crime_forms_common.prior_authority.messages.further_information')}"
            comments << further_information_explanation
          end

          if incorrect_information_explanation.present?
            comments << "## #{I18n.t('laa_crime_forms_common.prior_authority.messages.incorrect_information')}"
            comments << incorrect_information_explanation
          end

          comments.compact_blank.join("\n\n")
        end

        def incorrect_information_explanation
          @data["incorrect_information_explanation"]
        end

        def further_information_explanation
          @data["further_information_explanation"]
        end

        def date_to_respond_by
          Time.parse(@data["resubmission_deadline"]).strftime("%-d %B %Y")
        end
      end
    end
  end
end
