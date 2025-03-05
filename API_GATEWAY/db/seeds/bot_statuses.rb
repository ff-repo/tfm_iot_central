articles = [
  { code: '001', description: 'REGISTRATION' },
  { code: '002', description: 'OPERATING' },
  { code: '003', description: 'OUT' }
]

articles.each do |e|
  m = BotStatus.find_or_initialize_by(code: e[:code])
  m.assign_attributes(
    description: e[:description]
  )

  m.save!
end