# frozen_string_literal: true

class CreateBotStatuses < ActiveRecord::Migration[7.2]
  def change
    create_table :bot_statuses do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
