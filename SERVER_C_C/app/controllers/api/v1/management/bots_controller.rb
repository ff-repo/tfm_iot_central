# frozen_string_literal: true

module Api::V1::Management
  class BotsController < Api::V1::Management::BaseController
    include ClientGatewayHelper
    include ContentHelper
    include BotHelper

    def index
      b = Bot.all.map { |e| BotPresenter.new(e).resp_json }
      render_response_json(content: b)

    rescue StandardError => e
      process_error(e)
    end

    def show
      limit_size = bot_params[:limit_size].blank? ? 10 : bot_params[:limit_size].to_i
      limit_size = limit_size > 100 || limit_size <= 0 ? 10 : limit_size

      b = Bot.find_by(code: bot_params[:code])
      render_response_json(content: BotPresenter.new(b, b.bot_command_pools.get_last(limit: limit_size)).resp_json)

    rescue StandardError => e
      process_error(e)
    end

    def commands
      c = BotCommandPool.available_commands.map { |k, v| CommandPresenter.new(k, v).resp_json }
      render_response_json(content: c)

    rescue StandardError => e
      process_error(e)
    end

    def execute
      c = BotCommandPool.available_commands[command_params[:code].to_sym]

      raise CustomError.new(message: 'Bad Option', code: '1000') if c.blank?

      case c[:type]
      when 'deploy'
        client_gateway = ClientGateway.find_by(id: command_params[:client_gateway_id])

        raise CustomError.new(message: 'Bad Client Gateway', code: '1000') if client_gateway.blank?

        available_bots = Bot.available_to_use
        picked_bots = available_bots.sample(client_gateway.bot_size)
        picked_bots.each do |b|
          bot_client_config = {
            settings: generate_settings_for_bot_client(client_gateway),
            installer_link: get_client_installer_for_bot
          }

          settings = b.bot_settings.only_active
          settings.update(bot_client_config: bot_client_config)

          send_client_bots_settings(client_gateway.id)

          b.bot_command_pools.create(
            command: command_params[:code],
            metadata: {
              command: command_params[:code],
              type: c[:type],
              type_2: c[:type_2],
              extra: bot_client_config
            }
          )
        end

      else
        bots = Bot.where(code: command_params[:bots], active: true, bot_status: BotStatus.operating)
        bots.each do |b|
          next if b.shutdown_on_going? # Block command emission if bot are set for removing

          b.bot_command_pools.create(
            command: command_params[:code],
            metadata: {
              command: command_params[:code],
              type: c[:type],
              type_2: c[:type_2],
              type_3: c[:type_3],
              action: command_params[:shell_command]
            }
          )
        end
      end

      render_response_json(content: { message: 'Some bots may not active, only those ones active will run the command' })

    rescue StandardError => e
      process_error(e)
    end

    private

    def bot_params
      params.permit(:code, :limit_size)
    end

    def command_params
      params.permit(:code, :shell_command, :client_gateway_id, bots: [])
    end

    def process_error(e)
      if e.is_a?(CustomError)
        error = {
          code: e.code,
          msg: e.message
        }
      else
        error = {
          code: 1000,
          msg: 'Bad operation'
        }
      end

      render_response_json(error: error, status: :service_unavailable)
    end
  end
end
