# frozen_string_literal: true

class BotSetting < ApplicationRecord
  belongs_to :bot

  def self.only_active
    find_by(active: true)
  end
end
