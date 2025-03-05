# frozen_string_literal: true

class Parameter < ApplicationRecord
  def self.reg_uri
    find_by(code: 'reg_uri').value
  end

  def self.reg_pool
    find_by(code: 'reg_pool').value
  end

  def self.c_c_uri
    find_by(code: 'c_c_uri').value
  end

  def self.c_c_pool
    find_by(code: 'c_c_pool').value
  end

  def self.c_c_gateway_uri
    find_by(code: 'c_c_gateway_uri').value
  end

  def self.c_c_gateway_pool
    find_by(code: 'c_c_gateway_pool').value
  end

  def self.c_c_api_user_token
    find_by(code: 'c_c_api_user_token').value
  end

  def self.c_c_facade_repo
    find_by(code: 'c_c_facade_repo').value
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

  def self.deployer_host
    find_by(code: 'deployer_host').value
  end

  def self.deployer_user
    find_by(code: 'deployer_user').value
  end

  def self.deployer_file
    find_by(code: 'deployer_file').value
  end

  def self.deployer_passphrase
    find_by(code: 'deployer_passphrase').value
  end

  def self.bucket_admin_region
    find_by(code: 'bucket_admin_region').value
  end

  def self.bucket_admin_name
    find_by(code: 'bucket_admin_name').value
  end

  def self.bucket_admin_key_id
    find_by(code: 'bucket_admin_key_id').value
  end

  def self.bucket_admin_access_key
    find_by(code: 'bucket_admin_access_key').value
  end

  def self.bucket_facade_region
    find_by(code: 'bucket_facade_region').value
  end

  def self.bucket_facade_name
    find_by(code: 'bucket_facade_name').value
  end

  def self.bucket_facade_key_id
    find_by(code: 'bucket_facade_key_id').value
  end

  def self.bucket_facade_access_key
    find_by(code: 'bucket_facade_access_key').value
  end

  def self.bucket_facade_admin_bot_installer
    find_by(code: 'bucket_facade_admin_bot_installer').value
  end

  def self.bucket_facade_admin_bot_dependency
    find_by(code: 'bucket_facade_admin_bot_dependency').value
  end

  def self.bucket_facade_client_bot_installer
    find_by(code: 'bucket_facade_client_bot_installer').value
  end

  def self.bucket_facade_client_bot_dependency
    find_by(code: 'bucket_facade_client_bot_dependency').value
  end


end
