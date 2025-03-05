# frozen_string_literal: true

class CreateBots < ActiveRecord::Migration[7.2]
  def change
    create_table :bots do |t|
      t.string :code
      t.string :machine_id
      t.string :description
      t.boolean :active, default: false
      t.string :os_type
      t.string :os_version
      t.references :bot_status, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bots, :code, unique: true
  end
end
