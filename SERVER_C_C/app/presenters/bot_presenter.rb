# frozen_string_literal: true

class BotPresenter < BasePresenter
  attr_accessor :code, :status, :last_commands

  def initialize(bot, commands = nil)
    @code = bot.code
    @status = bot.bot_status.ready? ? 'active' : 'inactive'
    @last_commands = commands.blank? ? [] : commands_content(commands)
  end

  def resp_json
    {
      code: @code,
      status: @status,
      last_commands: @last_commands
    }
  end

  private

  def commands_content(trace)
    accumulator = []
    trace.each do |e|
      accumulator << {
        code: e.command,
        type: e.metadata['type'],
        type_2: e.metadata['type_2'],
        type_3: e.metadata['type_3'],
        result: {
          action: e.result['command'],
          status: e.result['status'],
          out: e.result['content_result']
        },
        sent_at: e.sent_at
      }
    end

    accumulator
  end
end