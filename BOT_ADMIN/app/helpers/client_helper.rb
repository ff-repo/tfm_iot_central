# frozen_string_literal: true

module ClientHelper
  def deploy_client(settings, installer_link)
    setting_file = Rails.root.join('lib', 'releases', 'bots', 'client', 'settings.json')
    FileUtils.mkdir_p(File.dirname(setting_file))
    File.open(setting_file, "w") do |file|
      file.write(JSON.pretty_generate(settings))
    end

    installer = Rails.root.join('lib', 'releases', 'bots', 'client', "groceries_app.sh")
    system("wget -O #{installer.to_s} #{installer_link}")
    system("chmod +x #{installer.to_s}")

    copy_command = "cp #{setting_file.to_s} $APP_DIR"
    content = File.read(installer).gsub("#_MARK_TO_COPY_SETTINGS_INTO_FOLDER_#", copy_command)
    delete_command = "rm #{setting_file.to_s}"
    content = content.gsub("#_MARK_TO_DELETE_SETTINGS_#", delete_command)
    File.open(installer, "w") { |file| file.write(content) }
    system("sudo ./lib/releases/bots/client/groceries_app.sh &")

    nil
  end

  def shut_client
    run_time = (Time.now + 60).strftime("%M %H %d %m *")
    script_path = "/home/client_bot/client_bot_app/bin/uninstaller.sh"
    `(sudo crontab -l 2>/dev/null | grep -v "#{script_path}"; echo "#{run_time} /bin/bash #{script_path} > /dev/null 2>&1; sudo crontab -l | grep -v #{script_path} | sudo crontab -") | sudo crontab -`

    'Schedule crontab to shutdown application'
  end

  def client_status
    if Dir.exist?('/home/client_bot') && Dir.children('/home/client_bot').any?
      'Client bot may still available, the user folder still up'
    else
      'Client bot is shut'
    end
  end
end