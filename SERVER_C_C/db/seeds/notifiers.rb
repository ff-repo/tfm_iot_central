# frozen_string_literal: true

include ApiTokenHelper

notifiers = [
  { uri: '', active: true }
]

notifiers.each do |e|
  m = Notifier.find_or_initialize_by(uri: e[:uri])
  m.assign_attributes(
    active: e[:active]
  )

  m.save!

  m.create_api_token!(
    token: generate_token,
    description: 'Web notifier',
    active: true
  ) if m.api_token.blank?
end

