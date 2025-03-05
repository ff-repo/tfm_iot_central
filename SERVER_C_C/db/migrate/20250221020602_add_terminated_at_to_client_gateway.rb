class AddTerminatedAtToClientGateway < ActiveRecord::Migration[7.2]
  def change
    add_column :client_gateways, :terminated_at, :timestamp
  end
end
