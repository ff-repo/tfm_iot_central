# frozen_string_literal: true

class Bot < ApplicationRecord
  belongs_to :bot_status
  has_many :bot_command_pools
  has_many :bot_settings

  def self.find_by_token(token)
    BotSetting.find_by("config #>> '{c_c,token}' = ?", token).try(:bot)
  end
end
