# frozen_string_literal: true

class CreateBots < ActiveRecord::Migration[7.2]
  def change
    create_table :bots do |t|
      t.string :code
      t.boolean :active, default: false
      t.references :bot_status, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bots, :code, unique: true
  end
end
