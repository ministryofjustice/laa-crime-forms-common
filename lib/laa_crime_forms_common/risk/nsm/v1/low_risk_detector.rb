module LaaCrimeFormsCommon
  module Risk
    module Nsm
      module V1
        class LowRiskDetector
          EVIDENCE_MULTIPLIER = 2
          WITNESS_MULTIPLIER = 30
          ADVOCACY_MULTIPLIER = 2

          def self.call(data)
            new(data).call
          end

          def initialize(data)
            @data = data
          end

          attr_accessor :data

          def call
            attendance_low_enough? && prep_low_enough?
          end

          def attendance_low_enough?
            total_time(%w[attendance_with_counsel attendance_without_counsel]) <= multiplied_total_advocacy_time
          end

          def prep_low_enough?
            total_time("preparation") - prep_allowances <= multiplied_total_advocacy_time
          end

          def prep_allowances
            evidence_allowance = (data["prosecution_evidence"] || 0) * EVIDENCE_MULTIPLIER
            statement_allowance = (data["defence_statement"] || 0) * EVIDENCE_MULTIPLIER
            video_allowance = (data["time_spent"] || 0) * EVIDENCE_MULTIPLIER
            witness_allowance = (data["number_of_witnesses"] || 0) * WITNESS_MULTIPLIER
            evidence_allowance + statement_allowance + video_allowance + witness_allowance
          end

          def total_time(work_type_or_types)
            work_types = Array(work_type_or_types)
            data["work_items"].select { work_types.include?(_1["work_type"]) }
                              .sum { _1["time_spent"] }
          end

          def multiplied_total_advocacy_time
            @multiplied_total_advocacy_time ||= ADVOCACY_MULTIPLIER * total_time("advocacy")
          end
        end
      end
    end
  end
end
