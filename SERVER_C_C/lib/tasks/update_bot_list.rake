# frozen_string_literal: true

namespace :update_bot_list do
  desc 'Update the status of bots'
  task :run => :environment do
    last_action_max = 10.minutes.ago

    Bot.where(active: true).each do |e|
      recent_activity = e.bot_tracks.last
      if recent_activity.blank? || (recent_activity.last_action <= last_action_max)
        e.update(active: false, bot_status: BotStatus.out)
        e.bot_settings.only_active.update(active: false) if e.bot_settings.only_active.present?
      end
    end

    Bot.where(machine_id: nil).each do |e|
      e.update(active: false, bot_status: BotStatus.out)
      e.bot_settings.only_active.update(active: false) if e.bot_settings.only_active.present?
    end
  end
end
