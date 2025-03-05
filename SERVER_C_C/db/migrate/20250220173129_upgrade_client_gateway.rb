class UpgradeClientGateway < ActiveRecord::Migration[7.2]
  def change
    add_column :client_gateways, :domain, :string
    add_column :client_gateways, :external_app_code, :string
    add_column :client_gateways, :cc_setting, :json
    add_column :client_gateways, :client_setting, :json
    add_column :client_gateways, :user_setting, :json
    add_column :client_gateways, :bot_size, :integer, default: 0

    remove_column :client_gateways, :crypt_config
    remove_column :client_gateways, :config
  end
end
