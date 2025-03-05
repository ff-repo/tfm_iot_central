# frozen_string_literal: true

module Api::V1::ClientGateways
  class ReceiverController < Api::V1::ClientGateways::BaseController
    include ClientGatewayHelper
    include CryptHelper
    include OffuscateHelper

    def index
      info = recover_payload
      case info[:type]
      when 'NOTICE'
        current_client_gateway.client_gateway_tracks.create_as_notice(info[:message])
      when 'INVALID_COMMAND'
        current_client_gateway.client_gateway_tracks.create_as_invalid_command(info[:message])
      end

      success_output
    end

    private

    def client_gateway_params
      params.permit(
        :name,
        :image,
        :url
      )
    end

    def recover_payload
      raise CustomError.new(message: 'Bad Token Api Client Gateway', fatal: true) if current_client_gateway.blank?

      setting = current_client_gateway.cc_setting
      recover_cg_payload(
        client_gateway_params[:image],
        client_gateway_params[:url],
        setting['pool'],
        setting['key'],
        setting['iv']
      ).with_indifferent_access
    end

  end
end
