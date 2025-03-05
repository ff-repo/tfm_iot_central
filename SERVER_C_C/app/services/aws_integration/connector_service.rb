# frozen_string_literal: true

module AwsIntegration
  class ConnectorService < ApplicationService
    def initialize
      aws_credentials = Aws::Credentials.new(Parameter.bucket_admin_key_id, Parameter.bucket_admin_access_key)
      @s3 = Aws::S3::Client.new(region: Parameter.bucket_admin_region, credentials: aws_credentials)
    end

    def download_object(download_path)
      File.open(download_path, 'wb') do |file|
        @s3.get_object({ bucket: Parameter.bucket_admin_name, key: Parameter.deployer_file }, target: download_path)
      end
    end
  end
end
