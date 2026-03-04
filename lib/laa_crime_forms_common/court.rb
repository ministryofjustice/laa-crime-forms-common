module LaaCrimeFormsCommon
  require "csv"
  class Court
    def initialize(id:, short_name:, name:)
      @id = id
      @short_name = short_name
      @name = name
    end

    attr_reader :id, :short_name, :name

    def ==(other)
      other.name == name
    end

    class << self
      def all
        @all ||= begin
          rows = csv_data
          rows.map { |r| new(id: r["id"], short_name: r["court_name"], name: r["combined_formatted"]) }
              .sort_by(&:name)
        end
      end

      def csv_file_path
        file = File.join(File.dirname(__dir__), "laa_crime_forms_common/courts.csv")
        File.read(file)
      end

      def csv_data
        @csv_data ||= CSV.parse(csv_file_path, col_sep: ",", row_sep: :auto, headers: true, skip_blanks: true)
      end
    end
  end
end
