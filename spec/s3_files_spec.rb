require_relative "../lib/laa_crime_forms_common/s3_files"
require "spec_helper"

RSpec.describe LaaCrimeFormsCommon::S3Files do
  describe ".temporary_download_url" do
    subject { described_class.temporary_download_url(s3_bucket, file_path, original_file_name) }
    let(:s3_bucket) { double(:s3_bucket) }
    let(:s3_object) { double(:s3_object) }
    let(:generated_url) { "GENERATED_URL" }
    let(:file_path) { "FILE_PATH" }
    let(:original_file_name) { "ORIGINAL_FILE_NAME.jpg" }

    before do
      allow(s3_bucket).to receive(:object).and_return(s3_object)
      allow(s3_object).to receive(:presigned_url).and_return(generated_url)
    end

    it "calls the appropriate AWS methods" do
      subject
      expect(s3_bucket).to have_received(:object).with(file_path)
      expect(s3_object).to have_received(:presigned_url).with(
        :get,
        expires_in: 30,
        response_content_disposition: "attachment; filename=\"#{original_file_name}\"; filename*=UTF-8''#{original_file_name}",
      )
    end

    it "returns the generated url" do
      expect(subject).to eq generated_url
    end

    context "when the file name has an unusual character in it" do
      let(:original_file_name) { "the–first-dash-in-this-file-name-is-an-unusual-one.pdf'" }

      it "escapes appropriately" do
        subject
        expect(s3_object).to have_received(:presigned_url).with(
          :get,
          expires_in: 30,
          response_content_disposition: "attachment; filename=\"the%E2%80%93first-dash-in-this-file-name-is-an-unusual-one.pdf%27\"; filename*=UTF-8''the%E2%80%93first-dash-in-this-file-name-is-an-unusual-one.pdf%27",
        )
      end
    end

    context "when the file name has a double quote in it" do
      let(:original_file_name) { 'file-with-"double-quotes".pdf' }

      it "escapes appropriately" do
        subject
        expect(s3_object).to have_received(:presigned_url).with(
          :get,
          expires_in: 30,
          response_content_disposition: "attachment; filename=\"file-with-%22double-quotes%22.pdf\"; filename*=UTF-8''file-with-%22double-quotes%22.pdf",
        )
      end
    end

    context "when the file name has spaces in it" do
      let(:original_file_name) { "file with spaces.pdf" }

      it "escapes appropriately" do
        subject
        expect(s3_object).to have_received(:presigned_url).with(
          :get,
          expires_in: 30,
          response_content_disposition: "attachment; filename=\"file%20with%20spaces.pdf\"; filename*=UTF-8''file%20with%20spaces.pdf",
        )
      end
    end
  end
end
