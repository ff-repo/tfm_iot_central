class CreateClientGateways < ActiveRecord::Migration[7.2]
  def change
    create_table :client_gateways do |t|
      t.string :description
      t.string :code
      t.timestamp :implemented_at
      t.string :requester_email
      t.json :config
      t.json :crypt_config
      t.boolean :active, default: false

      t.timestamps
    end

    add_index :client_gateways, :code, unique: true
  end
end
