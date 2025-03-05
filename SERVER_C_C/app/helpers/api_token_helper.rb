# frozen_string_literal: true

module ApiTokenHelper
  def generate_token
    SecureRandom.urlsafe_base64(24)
  end
end