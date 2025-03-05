# frozen_string_literal: true

class ClientGateway < ApplicationRecord
  scope :only_actives, -> { where(active: true) }
  scope :terminated, -> { where('terminated_at <= ? OR terminated_at IS NULL', Time.now) }

  has_one :api_token, as: :entity, dependent: :destroy
  has_many :bots
  has_many :client_gateway_tracks

  validates :description, presence: true
  validates_uniqueness_of :code
  validates :requester_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.find_by_token(token)
    find_by("active = true AND cc_setting #>> '{token}' = ?", token)
  end

  def format_uri_to_access(https = false)
    return "www.#{domain}" if !https

    "https://www.#{domain}"
  end
end
