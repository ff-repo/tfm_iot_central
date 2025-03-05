# frozen_string_literal: true

return if User.all.size > 0

user = User.new(username: USERNAME_TO_FILL, password: PASSWORD_TO_FILL, password_confirmation: PASSWORD_CONF_TO_FILL, email: EMAIL_USER_TO_FILL)
user.save!
