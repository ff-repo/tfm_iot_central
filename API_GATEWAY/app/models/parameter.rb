# frozen_string_literal: true

class Parameter < ApplicationRecord
  def self.c_c_uri
    find_by(code: 'c_c_uri').value
  end

  def self.c_c_pool
    find_by(code: 'c_c_pool').value
  end

  def self.c_c_cipher_key
    find_by(code: 'c_c_cipher_key').value
  end

  def self.c_c_cipher_iv
    find_by(code: 'c_c_cipher_iv').value
  end

  def self.c_c_token
    find_by(code: 'c_c_token').value
  end

  def self.client_c_uri
    find_by(code: 'client_c_uri').value
  end

  def self.client_c_pool
    find_by(code: 'client_c_pool').value
  end

  def self.client_user_token
    find_by(code: 'client_user_token').value
  end

  def self.enable_ip_filter
    find_by(code: 'enable_ip_filter').value == 'true'
  end

  def self.ip_range_filter
    find_by(code: 'ip_range_filter').value
  end

  def self.ip_statics_filter
    find_by(code: 'ip_statics_filter').value
  end
end
