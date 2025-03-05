class CreateClientGatewayTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :client_gateway_tracks do |t|
      t.references :client_gateway, null: false, foreign_key: true, index: true
      t.string :event_description
      t.string :event_type

      t.timestamps
    end
  end
end
