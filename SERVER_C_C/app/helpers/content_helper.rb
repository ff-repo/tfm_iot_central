# frozen_string_literal: true

module ContentHelper
  def get_admin_installer_source_base
    "https://www.#{Notifier.only_active.uri}"
  end

  def get_client_installer_for_bot
    "https://www.#{Notifier.only_active.uri}/groceries_app"
  end
end