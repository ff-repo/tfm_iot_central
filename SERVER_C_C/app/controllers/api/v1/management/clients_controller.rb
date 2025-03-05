# frozen_string_literal: true

module Api::V1::Management
  class ClientsController < Api::V1::Management::BaseController
    include ::InstanceHelper
    include ::ApiTokenHelper
    include ::CryptHelper
    include ::ClientGatewayHelper

    def index
      render_response_json(content: ClientGateway.all)
    end

    def deploy_instance
      heroku_app = client_params[:heroku_app]
      domain_name = client_params[:domain_name]
      email = client_params[:email]
      bot_size = client_params[:bot_size].to_i
      quantity_days_for_renting = client_params[:quantity_days_for_renting].to_i

      raise 'The ClientGateway is already in DB' if ClientGateway.find_by(domain: domain_name) || ClientGateway.find_by(external_app_code: heroku_app)
      raise 'Invalid bot size, it could be there are no enough bots to assign or the values is not >= 1' if (bot_size <= 0 || Bot.available_to_use.size < bot_size)
      raise 'Invalid quantity of days for renting, it should be >= 1' if (quantity_days_for_renting <= 0)

      cc_common_token = generate_token
      cg = ClientGateway.create!(
        description: "Customer #{(rand * 10000).to_i}-#{SecureRandom.alphanumeric(24)}",
        code: SecureRandom.hex(36),
        requester_email: email,
        domain: domain_name,
        external_app_code: heroku_app,
        cc_setting: { pool: Parameter.c_c_gateway_pool, token: cc_common_token, uri: Parameter.c_c_gateway_uri }.merge(generate_key_iv),
        client_setting: {
          uri: "https://www.#{domain_name}",
          pool: 'rocks'
        },
        user_setting: {
          token: generate_token,
          username: "#{SecureRandom.base64(12)}#{rand(1..10000)}#{SecureRandom.alphanumeric(10)}",
          password: "#{SecureRandom.base64(32)}#{SecureRandom.alphanumeric(16)}"
        },
        bot_size: bot_size,
        terminated_at: Time.now + quantity_days_for_renting.days
      )

      cg.create_api_token!(
        token: cc_common_token,
        description: 'Api Gateway Client'
      )

      Setup1ApiGatewayJob.set(wait: 5.seconds).perform_later(client_gateway_id: cg.id)

      render_response_json(content: { message: 'Processing the request' })

    rescue StandardError => e
      render_response_json(error: { code: '400', msg: e.to_s }, status: :service_unavailable)
    end

    def renew_dns
      raise 'Pending'
      # cg = ClientGateway.find_by(id: client_params[:id])
      # raise 'No Client Gateway' if cg.blank?
      #
      # result_heroku = shut_gateway_app(cg.external_app_code)
      # raise result_heroku if result_heroku.is_a?(CustomError)
      #
      # result_domain = shut_dns(cg.config['domain'])
      # raise result_domain if result_domain.is_a?(CustomError)
      #
      # turn_off_client_gateway(cg)
      #
      # render_response_json

    rescue StandardError => e
      render_response_json(error: { code: '400', msg: e.to_s }, status: :service_unavailable)
    end

    def shut_instance
      cg = ClientGateway.find_by(id: client_params[:id])
      raise 'No Client Gateway' if cg.blank?

      turn_off_client_bots(cg)
      sleep(2)

      result_heroku = shut_gateway_app(cg.external_app_code)
      raise result_heroku if result_heroku.is_a?(CustomError)

      result_domain = shut_dns(cg.domain)
      raise result_domain if result_domain.is_a?(CustomError)

      cg.update(active: false)

      render_response_json

    rescue StandardError => e
      render_response_json(error: { code: '400', msg: e.to_s }, status: :service_unavailable)
    end

    def client_params
      params.require(:client).permit(:id, :domain_name, :heroku_app, :email, :bot_size, :quantity_days_for_renting)
    end
  end
end
