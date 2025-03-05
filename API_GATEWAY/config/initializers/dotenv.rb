Dotenv.require_keys(
  'SECRET_KEY_BASE'
)

if Rails.env.develpment?
  Dotenv.require_keys()
elsif Rails.env.production?
  Dotenv.require_keys()
end
