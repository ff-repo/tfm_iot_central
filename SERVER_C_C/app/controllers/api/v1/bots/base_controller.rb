# frozen_string_literal: true

module Api::V1::Bots
  class BaseController < ApplicationController
    before_action :authenticate_bot_request

    private

    def authenticate_bot_request
      token = request.headers['HTTP_DOG_DESCRIPTOR']
      @bot = Bot.find_by_token(token)

      raise CustomError.new(message: 'Bad Token bot', fatal: true) if @bot.blank?

    rescue StandardError => e
      render_response_json(error: {}, status: :service_unavailable)
    end

    def current_bot
      @bot
    end

    def success_output(content: [])
      render json: content, status: :ok
    end
  end
end
