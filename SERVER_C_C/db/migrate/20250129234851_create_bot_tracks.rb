# frozen_string_literal: true

class CreateBotTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :bot_tracks do |t|
      t.references :bot, null: false, foreign_key: true, index: true
      t.timestamp :last_action
      t.string :ip

      t.timestamps
    end
  end
end
