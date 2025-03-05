# frozen_string_literal: true

class Bot < ApplicationRecord
  scope :only_actives, -> { where(active: true) }
  scope :available_to_use, -> { only_actives.includes(:bot_settings).where(client_gateway_id: nil) }

  belongs_to :bot_status
  belongs_to :client_gateway, optional: true
  has_many :bot_command_pools
  has_many :bot_settings
  has_many :bot_tracks

  def self.find_by_token(token)
    BotSetting.find_by("active = true AND config #>> '{c_c,token}' = ?", token).try(:bot)
  end

  def track_as_normal_operation(description: nil, ip: nil, type: 'normal')
    BotTrack.create(bot_id: id, ip: ip, description: description, kind: BotTrack::REGISTER_TYPES[type.to_sym])
  end

  def turn_off
    bot_settings.only_active.update(active: false, bot_client_config: {}) if bot_settings.only_active.present?
    update(active: false, bot_status: BotStatus.out, client_gateway_id: nil)
  end

  def client_shutdown_on_going?
    bot_command_pools.pending_to_send.where(command: BotCommandPool::COMMANDS_TYPE_CODES['CLIENT_SHUT_DEPLOYMENT']).size > 0
  end

  def shutdown_on_going?
    bot_command_pools.pending_to_send.where(command: BotCommandPool::COMMANDS_TYPE_CODES['REMOVE_BOT']).size > 0
  end
end
