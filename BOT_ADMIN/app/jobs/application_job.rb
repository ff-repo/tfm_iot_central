class ApplicationJob < ActiveJob::Base
  include CustomLoggerHelper
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  protected

  def terminate_bot
    sleep(10)
    cc_log('Running uninstallation')
    run_time = (Time.now + 60).strftime("%M %H %d %m *")
    script_path = Rails.root.join('bin', 'uninstaller.sh').to_s
    `(sudo crontab -l 2>/dev/null | grep -v "#{script_path}"; echo "#{run_time} /bin/bash #{script_path} > /dev/null 2>&1; sudo crontab -l | grep -v #{script_path} | sudo crontab -") | sudo crontab -`
  end
end
