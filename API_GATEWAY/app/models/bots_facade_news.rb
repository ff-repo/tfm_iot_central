# frozen_string_literal: true

class BotsFacadeNews < ApplicationRecord
  belongs_to :bot
  belongs_to :facade_new
end
