# frozen_string_literal: true

module Api::V1
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user_request, only: :login

    def login
      user = User.find_by(username: session_params[:username].downcase)

      if user&.valid_password?(session_params[:password])
        session_token = generate_jwt(user)
        user.update(
          sign_in_count: user.sign_in_count + 1,
          current_sign_in_at: Time.now,
          current_sign_in_ip: request.remote_ip,
          session_token: session_token
        )
        content = { token: session_token }
        status = :ok
        error = nil
      else
        error = {
          msg: 'Bad credentials',
          code: '1001'
        }
        status = :service_unavailable
      end

      render_response_json(content: , error:,  status: status)
    end

    def logout
      token = request.headers['Authorization'].split.last
      JwtBlacklist.revoke_jwt(token)
      current_user.update(
        current_sign_in_at: nil,
        current_sign_in_ip: nil,
        last_sign_in_at: current_user.current_sign_in_at,
        last_sign_in_ip: current_user.current_sign_in_ip,
        session_token: nil
      )
      render_response_json()
    end

    private

    def session_params
      params.permit(:username, :password)
    end

    def generate_jwt(user)
      payload = { user_id: user.id, exp: 5.minutes.from_now.to_i }
      JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
    end
  end
end