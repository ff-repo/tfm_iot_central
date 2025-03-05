# frozen_string_literal: true

class CreateBotCommandPools < ActiveRecord::Migration[7.2]
  def change
    create_table :bot_command_pools do |t|
      t.references :bot, null: false, foreign_key: true, index: true
      t.string :command
      t.json :metadata
      t.json :result
      t.timestamp :sent_at

      t.timestamps
    end
  end
end
