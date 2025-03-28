# frozen_string_literal: true

class Parameter < ApplicationRecord
  def self.client_interface_deploy
    find_by(code: 'client_interface_deploy').value == 'true'
  end

  def self.c_c_interface_deploy
    find_by(code: 'c_c_interface_deploy').value == 'true'
  end

  def self.c_c_fails_counter
    find_by(code: 'c_c_fails_counter').value.to_i
  end

  def self.c_c_uri
    find_by(code: 'c_c_uri').value
  end

  def self.c_c_pool
    find_by(code: 'c_c_pool').value
  end

  def self.c_c_token
    find_by(code: 'c_c_token').value
  end

  def self.c_c_cipher_key
    find_by(code: 'c_c_cipher_key').value
  end

  def self.c_c_cipher_iv
    find_by(code: 'c_c_cipher_iv').value
  end

  def self.bot_id
    find_by(code: 'bot_id').value
  end

  def self.custom_update(code_name, value_save)
    find_by(code: code_name).update(value: value_save.to_s)
  end

  def self.reset_internal_control
    [
      ['c_c_fails_counter', 0]
    ].map { |e| custom_update(e[0], e[1]) }
  end
end
