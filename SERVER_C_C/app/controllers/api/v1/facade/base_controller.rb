# frozen_string_literal: true

module Api::V1::Facade
  class BaseController < ApplicationController
    before_action :check_api_token

    private

    def check_api_token
      api_token = request.headers['Api-Token']
      raise 'Lack of API Token' if api_token.blank?

      n = Notifier.only_active
      raise 'Bad API Token' if n.api_token.token != api_token
    rescue StandardError => e
      render_response_json(error: {}, status: :service_unavailable)
    end
  end
end
