# parameters = [
#   { code: 'c_c_uri' },
#   { code: 'c_c_pool' },
#   { code: 'c_c_cipher_key' },
#   { code: 'c_c_cipher_iv' },
#   { code: 'c_c_token' },
#   { code: 'client_c_uri' },
#   { code: 'client_c_pool' },
#   { code: 'client_user_token' },
# ]
#
# parameters.each do |e|
#   m = Parameter.find_or_initialize_by(code: e[:code])
#   m.assign_attributes(
#     description: e[:description],
#     value: e[:value]
#   )
#
#   m.save!
# end
