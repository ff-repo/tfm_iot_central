# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :check_user_api_token
  before_action :authenticate_user_request

  private

  def authenticate_bot_request
    token = request.headers['HTTP_GROCERY_DESCRIPTOR']
    @bot = Bot.find_by_token(token)

    raise CustomError.new(message: 'Bad Token bot', fatal: true) if @bot.blank?

  rescue StandardError => e
    render_response_json(error: {}, status: :service_unavailable)
  end

  def current_bot
    @bot
  end

  def process_error(exception = nil)
    do_log(msg: 'General Message', exception: exception)

    error_output
  end

  def do_log(msg: 'General Message', exception: nil)
    if exception.present?
      puts exception
      return
    end

    puts msg
  end

  def success_output(content: [])
    render json: content, status: :ok
  end

  def error_output
    render json: [], status: :service_unavailable
  end

  def render_response_json(content: [], error: nil, status: 200)
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

  def check_user_api_token
    api_token = request.headers['Api-Token']
    raise 'Lack of API Token' if api_token != Parameter.client_user_token
  rescue StandardError => e
    render_response_json(error: {}, status: :service_unavailable)
  end

  def authenticate_user_request
    header = request.headers['Authorization']
    token = header.present? ? header.split.last : nil

    raise 'Invalid Token' if JwtBlacklist.jwt_revoked?(token)

    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')

    @current_user = User.find(decoded[0]['user_id'])
  rescue StandardError => e
    JwtBlacklist.revoke_jwt(token) if e.is_a?(JWT::ExpiredSignature)
    render_response_json(error: { msg: 'Require Login', code: '1001' }, status: :service_unavailable)
  end

  def current_user
    @current_user
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
