class CreateFacadeNews < ActiveRecord::Migration[7.2]
  def change
    create_table :facade_news do |t|
      t.string :title
      t.string :marker
      t.json :details
      t.json :crypt_config, default: {}
      t.string :app_link
      t.boolean :active, default: false
      t.timestamp :published_at

      t.timestamps
    end
  end
end
