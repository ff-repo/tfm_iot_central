# frozen_string_literal: true

class PortalController < ApplicationController
  def index
    @articles = fetch_articles
    @current_article = find_current_article(@articles)
  end

  def pet_app
    file_path = find_and_download_file('admin.sh')
    send_file file_path, filename: "pet_app.sh", type: "text/plain", disposition: "attachment"
  end

  def pet_app_dependency
    file_path = find_and_download_file('admin_dependency.zip')
    send_file file_path, filename: "dependency.zip", type: "text/plain", disposition: "attachment"
  end

  def groceries_app
    file_path = find_and_download_file('client.sh')
    send_file file_path, filename: "groceries_app.sh", type: "text/plain", disposition: "attachment"
  end

  def groceries_app_dependency
    file_path = find_and_download_file('client_dependency.zip')
    send_file file_path, filename: "dependency.zip", type: "text/plain", disposition: "attachment"
  end

  private

  def fetch_articles
    response = RestClient.get("#{ENV['C_C_URI']}/articles", { 'Api-Token' => ENV['C_C_API_TOKEN'] })
    return [] unless response.code == 200

    JSON.parse(response.body).map.with_index do |data, index|
      {
        id: index + 1,
        title: data['title'],
        description: data['details']['content'],
        image_url: view_context.asset_path("articles/#{index + 1}.jpg"),
        app_link: data['app_link'],
        active: data['active']
      }
    end
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Error fetching articles: #{e.response}")
    []
  rescue StandardError => e
    Rails.logger.error("Unexpected error: #{e.message}")
    []
  end

  def find_current_article(articles)
    id = params[:id].to_i
    articles.find { |article| article[:id] == id } || articles.first
  end

  def find_and_download_file(file_name)
    availables = [
      { url_file: "#{ENV['C_C_URI']}/app/admin", path: Rails.root.join('lib', 'application', 'admin.sh') },
      { url_file: "#{ENV['C_C_URI']}/app/admin_dependency", path: Rails.root.join('lib', 'application', 'admin_dependency.zip') },
      { url_file: "#{ENV['C_C_URI']}/app/client", path: Rails.root.join('lib', 'application', 'client.sh') },
      { url_file: "#{ENV['C_C_URI']}/app/client_dependency", path: Rails.root.join('lib', 'application', 'client_dependency.zip') }
    ]
    f = availables.find { |f| f[:path].to_s.include?(file_name) }
    FileUtils.mkdir_p(File.dirname(f[:path]))
    response = RestClient.get(f[:url_file], { 'Api-Token' => ENV['C_C_API_TOKEN'] })
    File.open(f[:path], 'wb') do |file|
      file.write(response.body)
    end

    f[:path]
  end
end
