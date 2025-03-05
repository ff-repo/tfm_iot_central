articles = [
  { code: 'reg_uri', description: 'URI for Registration', value: 'https://example.com' },
  { code: 'reg_pool', description: 'Pool for Registration', value: 'example' },
  { code: 'c_c_uri', description: 'URI for C_C', value: 'https://example2.com' },
  { code: 'c_c_pool', description: 'Pool for C_C', value: 'example2' },
  { code: 'c_c_gateway_uri', description: 'URI for API Gateways to communicate with CC', value: 'https://example3.com' },
  { code: 'c_c_gateway_pool', description: 'Pool for API Gateways to communicate with CC', value: 'example3' },
  { code: 'c_c_api_user_token', description: 'API user Token to manage CC', value: 'token' },
  { code: 'c_c_facade_repo', description: 'URI for C_C', value: 'https://example4.com' },
  { code: 'enable_ip_filter', description: 'IP filtering', value: 'true' },
  { code: 'ip_range_filter', description: 'IP filtering', value: '127.0.0.0/24' },
  { code: 'ip_statics_filter', description: 'IP filtering', value: '127.0.0.1' },
  { code: 'deployer_host', description: 'Deployer setting', value: 'ec2_uri_or_ip' },
  { code: 'deployer_user', description: 'Deployer setting', value: 'ec2_username' },
  { code: 'deployer_file', description: 'Deployer setting', value: 'private_key_file_name_on_s3' },
  { code: 'deployer_passphrase', description: 'Deployer setting', value: 'private_key_passphrase' },
  { code: 'bucket_admin_region', description: 'Bucket setting', value: 'bucket_region_1' },
  { code: 'bucket_admin_name', description: 'Bucket setting', value: 'bucket_region_name_1' },
  { code: 'bucket_admin_key_id', description: 'Bucket setting', value: 'user_key_id_with_bucket_access_1' },
  { code: 'bucket_admin_access_key', description: 'Bucket setting', value: 'user_access_key_with_bucket_access_1' },
  { code: 'bucket_facade_region', description: 'Bucket setting', value: 'bucket_region_2' },
  { code: 'bucket_facade_name', description: 'Bucket setting', value: 'bucket_region_name_2' },
  { code: 'bucket_facade_key_id', description: 'Bucket setting', value: 'user_key_id_with_bucket_access_2' },
  { code: 'bucket_facade_access_key', description: 'Bucket setting', value: 'user_access_key_with_bucket_access_2' },
  { code: 'bucket_facade_admin_bot_installer', description: 'Installer files', value: 's3_object_name_identifier_1' },
  { code: 'bucket_facade_admin_bot_dependency', description: 'Installer files', value: 's3_object_name_identifier_2' },
  { code: 'bucket_facade_client_bot_installer', description: 'Installer files', value: 's3_object_name_identifier_3' },
  { code: 'bucket_facade_client_bot_dependency', description: 'Installer files', value: 's3_object_name_identifier_4' }
]

articles.each do |e|
  m = Parameter.find_or_initialize_by(code: e[:code])
  next if m.persisted?

  m.assign_attributes(
    description: e[:description],
    value: e[:value]
  )

  m.save!
end
