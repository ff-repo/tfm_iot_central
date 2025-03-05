class AddClientGatewayToBots < ActiveRecord::Migration[7.2]
  def change
    add_reference :bots, :client_gateway, foreign_key: true, index: true
  end
end