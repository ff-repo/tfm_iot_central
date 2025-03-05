class CreateParameters < ActiveRecord::Migration[7.1]
  def change
    create_table :parameters do |t|
      t.string :code
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
