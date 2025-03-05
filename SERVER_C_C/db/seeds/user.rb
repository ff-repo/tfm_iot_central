# frozen_string_literal: true
return if User.all.size > 0

include ApiTokenHelper

password = SecureRandom.base64(48)
username = SecureRandom.hex(24)
api_token = generate_token

u = User.find_or_initialize_by(email: 'any_email@email.com')
u.assign_attributes(
  password: password,
  username: username
)
u.save!

Parameter.find_by(code: 'c_c_api_user_token').update(value: api_token)

puts "User upderted: \n username: #{username} \n password: #{password} \n API token: #{api_token}"