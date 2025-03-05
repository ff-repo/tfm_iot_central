# frozen_string_literal: true

[
  ['dos_active', false],
  ['client_c_interface_deploy', false],
  ['client_c_fails_counter', 0],
  ['client_c_uri', ''],
  ['client_c_pool', ''],
  ['client_c_token', ''],
  ['client_c_cipher_key', ''],
  ['client_c_cipher_iv', ''],
  ['bot_id', ''],
  ['dos_slow', false]
].each do |p|
  e = Parameter.find_or_initialize_by(code: p[0])
  e.value = p[1].to_s
  e.save
end