# frozen_string_literal: true

module AwsIntegration
  class FacadeService < ApplicationService
    def initialize
      aws_credentials = Aws::Credentials.new(Parameter.bucket_facade_key_id, Parameter.bucket_facade_access_key)
      @s3 = Aws::S3::Client.new(region: Parameter.bucket_facade_region, credentials: aws_credentials)
    end

    def upload_object(new_file_path, s3_package_path)
      @s3.put_object(bucket: Parameter.bucket_facade_name, key: s3_package_path, body: File.open(new_file_path, 'rb'))
    end

    def download_object(key, download_path)
      FileUtils.mkdir_p(File.dirname(download_path))
      File.open(download_path, 'wb') do |file|
        @s3.get_object({ bucket: Parameter.bucket_facade_name, key: key }, target: download_path)
      end
    end
  end
end
