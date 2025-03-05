class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :custom_ip_filter

  def custom_ip_filter
    return if ENV['ENABLE_IP_FILTER'] != 'true'

    ip_range = IPAddr.new(ENV['IP_RANGE_FILTER'])
    request_ip = IPAddr.new(request.remote_ip)

    raise "BLOCK IP **#{request.remote_ip}**" if !ip_range.include?(request_ip)

  rescue StandardError => e
    render plain: '', status: :service_unavailable
  end
end
