# frozen_string_literal: true

module Webhooks
  class ReceiverController < Webhooks::BaseController
    include ::CcHelper

    def index
      info = recover_payload

      case info['action']
      when 'LOAD_BOT_SETTINGS'
        info['bots'].each do |e|
          b = Bot.find_or_initialize_by(code: e[:code])
          next if b.persisted? && b.active

          b.assign_attributes(
            active: false,
            bot_status: BotStatus.registration
          )
          b.save

          setting = b.bot_settings.only_active || b.bot_settings.new
          setting.assign_attributes(
            config: {
              c_c: {
                uri: e[:client_c_uri],
                pool: e[:client_c_pool],
                token: e[:client_c_token]
              }
            },
            crypt_config: {
              key: e[:client_c_cipher_key],
              iv: e[:client_c_cipher_iv]
            },
            active: true
          )
          setting.save
        end

        report_to_cc(generic_info: 'Loaded bot config')
      end


      success_output(content: [])
    end

    private

    def cc_params
      params.permit(
        :name,
        :image,
        :url
      )
    end

    def recover_payload
      raise CustomError.new(message: 'Bad Token Api Client Gateway', fatal: true) if cc_params.blank?

      recover_cc_payload(
        cc_params[:image],
        cc_params[:url],
        Parameter.c_c_pool,
        Parameter.c_c_cipher_key,
        Parameter.c_c_cipher_iv
      ).with_indifferent_access
    end
  end
end