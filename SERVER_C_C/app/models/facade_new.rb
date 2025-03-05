# frozen_string_literal: true

class FacadeNew < ApplicationRecord
  has_one :api_token, as: :entity

  def self.only_active
    find_by(active: true)
  end
end
