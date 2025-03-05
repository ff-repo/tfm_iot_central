# frozen_string_literal: true

class CreateBotSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :bot_settings do |t|
      t.references :bot, null: false, foreign_key: true, index: true
      t.json :config
      t.json :crypt_config
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
