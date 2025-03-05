# frozen_string_literal: true

module Api::V1::Management
  class SessionController < Api::V1::Management::BaseController
    skip_before_action :authenticate_user_request, only: :login

    def login
      user = User.find_by(username: session_params[:username].downcase)  # Find user by email or username

      if user&.valid_password?(session_params[:password])
        content = { token: generate_jwt(user) }
        status = :ok
        error = nil
      else
        content = nil
        error = {
          msg: 'Bad credentials',
          code: '1001'
        }
        status = 400
      end

      render_response_json(content: , error:,  status: status)
    end

    def logout
      token = request.headers['Authorization'].split.last
      JwtBlacklist.revoke_jwt(token)
      render_response_json()
    end

    private

    def session_params
      params.permit(:username, :password)
    end

    def generate_jwt(user)
      payload = { user_id: user.id, exp: 1.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
    end
  end
end
