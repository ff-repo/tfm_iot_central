# frozen_string_literal: true

module Webhooks
  class BaseController < ApplicationController
    skip_before_action :check_user_api_token
    skip_before_action :authenticate_user_request

    before_action :authenticate_cc

    def authenticate_cc
      token = request.headers['HTTP_DELIVERY_DESCRIPTOR']

      raise CustomError.new(message: 'Bad Token C&C', fatal: true) if Parameter.c_c_token != token

    rescue StandardError => e
      render_response_json(error: {}, status: :service_unavailable)
    end
  end
end