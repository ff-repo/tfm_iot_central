# frozen_string_literal: true

class ApiToken < ApplicationRecord
  scope :only_active, -> { where(active: true) }

  belongs_to :entity, polymorphic: true

  validates :description, presence: true
  validates :token, presence: true
  validates_presence_of :entity
  validates_uniqueness_of :token
end
