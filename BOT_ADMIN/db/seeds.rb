# frozen_string_literal: true

[
  ['client_interface_deploy', false],
  ['c_c_interface_deploy', false],
  ['c_c_fails_counter', 0],
  ['c_c_uri', ''],
  ['c_c_pool', ''],
  ['c_c_token', ''],
  ['c_c_cipher_key', ''],
  ['c_c_cipher_iv', ''],
  ['bot_id', ''],
].each do |p|
  e = Parameter.find_or_initialize_by(code: p[0])
  e.value = p[1].to_s
  e.save
end