class CreateApiTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :api_tokens do |t|
      t.string :token
      t.string :description
      t.boolean :active, default: false
      t.references :entity, polymorphic: true, index: true

      t.timestamps
    end
  end
end
