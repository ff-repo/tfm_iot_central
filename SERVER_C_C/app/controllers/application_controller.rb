# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :custom_ip_filter

  def process_error(exception = nil)
    if exception.present?
      Bugsnag.notify(exception)
      puts exception
    end

    render_response_json(content: '', status: :service_unavailable)
  end

  def render_response_json(content: '', error: nil, status: 200)
    if error.present?
      resp_body = {
        error: {
          code: error[:code],
          message: error[:msg],
        }
      }

      if status == 200
        status = :service_unavailable
      else
        status = status
      end

    else
      resp_body = content

    end

    render json: resp_body, status:
  end

  def custom_ip_filter
    return if !Parameter.enable_ip_filter

    request_ip = IPAddr.new(request.remote_ip)

    # Check static IPs
    Parameter.ip_statics_filter.split(',').each do |ip|
      return if ip == request_ip.to_s
    end

    Parameter.ip_range_filter.split(',').each do |ip_range|
      return if IPAddr.new(ip_range).include?(request_ip)
    end

    raise "BLOCK IP **#{request.remote_ip}**"

  rescue StandardError => e
    render_response_json(status: :service_unavailable)
  end
end
