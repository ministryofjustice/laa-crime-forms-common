require "spec_helper"

RSpec.describe "Schema validity" do
  let(:checker) do
    lambda do |properties, parent_attributes|
      properties.each do |name, attributes|
        if Array(attributes["type"]).include?("object")
          checker.call(attributes["properties"], parent_attributes + [name])
        elsif Array(attributes["type"]).include?("array")
          checker.call({ name => attributes["items"] }, parent_attributes)
        elsif Array(attributes["type"]).include?("null") && attributes["enum"]
          expect(attributes["enum"]).to(
            include(nil),
            "#{parent_attributes.join('->')}->#{name} is a nullable enum but without null in the enum",
          )
        end
      end
    end
  end

  describe "PA schema" do
    let(:schema_file) { JSON.load_file(File.join(__dir__, "../lib/schemas/prior_authority/v1.json")) }

    it "ensures nullable enums are correctly defined" do
      checker.call(schema_file["properties"], [])
    end
  end

  describe "NSM schema" do
    let(:schema_file) { JSON.load_file(File.join(__dir__, "../lib/schemas/nsm/v1.json")) }

    it "ensures nullable enums are correctly defined" do
      checker.call(schema_file["properties"], [])
    end
  end
end
