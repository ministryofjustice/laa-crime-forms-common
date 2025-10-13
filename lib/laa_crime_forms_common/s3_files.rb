require "uri"

# This class exists to generate user-friendly, temporary download URLs for
# files stored in S3. Specifically it handled:
# - Making sure the files expire
# - Making sure that the file is downloaded by the browser
# - Making sure that the filename of the downloaded file is valid

# It assumes that s3_bucket is an appropriately configured Aws::S3::Bucket object
module LaaCrimeFormsCommon
  class S3Files
    PRESIGNED_EXPIRY = 30

    def self.temporary_download_url(s3_bucket, file_key, original_file_name)
      escaped = URI.encode_uri_component(original_file_name)
      response_content_disposition = "attachment; filename=\"#{escaped}\"; filename*=UTF-8''#{escaped}"
      s3_bucket.object(file_key)
               .presigned_url(:get,
                              expires_in: PRESIGNED_EXPIRY,
                              response_content_disposition:)
    end
  end
end
