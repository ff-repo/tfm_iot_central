commands = [
  # { bot_id: Bot.first.id, command: 'echo "hello 123"', metadata: { type: 'system' } },
  # { bot_id: Bot.first.id, command: 'echo $USER!!!', metadata: { type: 'system' } }
]

commands.each do |e|
  m = BotCommandPool.find_or_initialize_by(bot_id: e[:bot_id], command: e[:command])
  m.assign_attributes(
    metadata: e[:metadata]
  )

  m.save!
end