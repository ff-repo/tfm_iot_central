# frozen_string_literal: true

module Api::V1::Facade
  class ContentController < Api::V1::Facade::BaseController
    def index
      accumulator = []
      FacadeNew.all.each do |e|
        accumulator << {
          title: e.title,
          details: e.details,
          marker: e.marker,
          app_link: e.app_link,
          active: e.active
        }
      end

      render_response_json(content: accumulator)
    rescue StandardError => e
      process_error(e)
    end

    def admin
      file_path = Rails.root.join('tmp', 'releases', 'bots', 'admin.sh')
      AwsIntegration::FacadeService.new.download_object(Parameter.bucket_facade_admin_bot_installer, file_path)
      send_file file_path, filename: 'admin.sh', type: 'text/plain', disposition: 'attachment'
    end

    def admin_dependency
      file_path = Rails.root.join('tmp', 'releases', 'bots', 'admin_dependency.zip')
      AwsIntegration::FacadeService.new.download_object(Parameter.bucket_facade_admin_bot_dependency, file_path)
      send_file file_path, filename: 'admin_dependency.zip', type: 'text/plain', disposition: 'attachment'
    end

    def client
      file_path = Rails.root.join('tmp', 'releases', 'bots', 'client.sh')
      AwsIntegration::FacadeService.new.download_object(Parameter.bucket_facade_client_bot_installer, file_path)
      send_file file_path, filename: 'client.sh', type: 'text/plain', disposition: 'attachment'
    end

    def client_dependency
      file_path = Rails.root.join('tmp', 'releases', 'bots', 'client_dependency.zip')
      AwsIntegration::FacadeService.new.download_object(Parameter.bucket_facade_client_bot_dependency, file_path)
      send_file file_path, filename: 'client_dependency.zip', type: 'text/plain', disposition: 'attachment'
    end
  end
end
