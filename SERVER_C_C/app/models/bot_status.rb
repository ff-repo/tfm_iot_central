# frozen_string_literal: true

class BotStatus < ApplicationRecord
  has_many :bots

  def self.registration
    find_by(code: '001')
  end

  def self.operating
    find_by(code: '002')
  end

  def self.out
    find_by(code: '003')
  end

  def valid_to_registered?
    [nil, '001', '002'].include?(code)
  end

  def ready?
    ['002'].include?(code)
  end
end
