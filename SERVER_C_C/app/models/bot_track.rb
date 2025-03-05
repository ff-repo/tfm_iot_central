# frozen_string_literal: true

class BotTrack < ApplicationRecord
  REGISTER_TYPES = {
    normal: 'NORMAL'
  }.with_indifferent_access

  belongs_to :bot

  before_save do |e|
    e.last_action = Time.now
  end
end
