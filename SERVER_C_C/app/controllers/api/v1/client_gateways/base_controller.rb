# frozen_string_literal: true

module Api::V1::ClientGateways
  class BaseController < ApplicationController
    before_action :authenticate_client_gateway_request

    private

    def authenticate_client_gateway_request
      token = request.headers['HTTP_DELIVERY_DESCRIPTOR']
      @client_gateway = ClientGateway.find_by_token(token)

      raise CustomError.new(message: 'Bad Token API Client Gateway', fatal: true) if @client_gateway.blank?
      raise CustomError.new(message: 'API Client Gateway is off', fatal: true) if !@client_gateway.active

    rescue StandardError => e
      render_response_json(error: {}, status: :service_unavailable)
    end

    def current_client_gateway
      @client_gateway
    end

    def success_output(content: [])
      render json: content, status: :ok
    end
  end
end
