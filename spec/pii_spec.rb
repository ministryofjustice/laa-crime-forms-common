require "spec_helper"

RSpec.describe "PII" do
  let(:checker) do
    lambda do |properties, parent_attributes|
      properties.each do |name, attributes|
        if Array(attributes["type"]).include?("object")
          checker.call(attributes["properties"], parent_attributes + [name])
        elsif Array(attributes["type"]).include?("array")
          checker.call({ name => attributes["items"] }, parent_attributes)
        else
          expect(attributes["x-pii"]).not_to(
            be_nil,
            "#{parent_attributes.join('->')}->#{name} does not have a PII definition",
          )
        end
      end
    end
  end

  describe "PA schema" do
    let(:schema_file) { JSON.load_file(File.join(__dir__, "../lib/schemas/prior_authority/v1.json")) }

    it "explicitly marks every property as PII or not" do
      checker.call(schema_file["properties"], [])
    end
  end

  describe "NSM schema" do
    let(:schema_file) { JSON.load_file(File.join(__dir__, "../lib/schemas/nsm/v1.json")) }

    it "explicitly marks every property as PII or not" do
      checker.call(schema_file["properties"], [])
    end
  end
end
