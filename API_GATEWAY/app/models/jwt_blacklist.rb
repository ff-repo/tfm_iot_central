# frozen_string_literal: true

class JwtBlacklist < ApplicationRecord
  def self.jwt_revoked?(token)
    JwtBlacklist.exists?(jti: token)
  end

  def self.revoke_jwt(token)
    JwtBlacklist.create!(jti: token)
  end
end
