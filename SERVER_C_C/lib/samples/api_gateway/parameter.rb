parameters = [
  { code: 'c_c_uri', description: 'URI for CC', value: C_C_URI_TO_FILL },
  { code: 'c_c_pool', description: 'Pool for CC', value: C_C_POOL_TO_FILL },
  { code: 'c_c_cipher_key', description: 'Key for CC', value: C_C_CIPHER_KEY_TO_FILL },
  { code: 'c_c_cipher_iv', description: 'IV for CC', value: C_C_CIPHER_IV_TO_FILL },
  { code: 'c_c_token', description: 'Token for CC', value: C_C_TOKEN_TO_FILL },
  { code: 'client_c_uri', description: 'URI for C_C', value: CLIENT_C_URI_TO_FILL },
  { code: 'client_c_pool', description: 'Pool for C_C', value: CLIENT_C_POOL_TO_FILL },
  { code: 'client_user_token', description: 'API Token for user', value: CLIENT_USER_TOKEN_TO_FILL }
]

parameters.each do |e|
  m = Parameter.find_or_initialize_by(code: e[:code])
  m.assign_attributes(
    description: e[:description],
    value: e[:value]
  )

  m.save!
end


