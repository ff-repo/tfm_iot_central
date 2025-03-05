# frozen_string_literal: true

module Api::V1::Management
  class BaseController < ApplicationController
    before_action :check_user_api_token
    before_action :authenticate_user_request

    private

    def check_user_api_token
      api_token = request.headers['Api-Token']
      raise 'Lack of API Token' if api_token != Parameter.c_c_api_user_token
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
      render_response_json(error: { msg: 'Require Login', code: '1001' }, status: :service_unavailable)
    end

    def current_user
      @current_user
    end
  end
end

