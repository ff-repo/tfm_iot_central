# frozen_string_literal: true

class CreateNotifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :notifiers do |t|
      t.string :uri
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
