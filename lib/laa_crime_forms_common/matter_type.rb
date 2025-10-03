require "i18n"

module LaaCrimeFormsCommon
  class MatterType
    attr_reader :id

    IDS = (1..16).map(&:to_s).freeze

    def initialize(id)
      @id = id
    end

    def self.all
      @all ||= IDS.map { |matter_id| new(matter_id) }
    end

    def description
      I18n.t(".laa_crime_forms_common.nsm.matter_type.#{id}")
    end

    def name
      "#{id} - #{description}"
    end
  end
end
