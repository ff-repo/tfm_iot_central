class CreateParameters < ActiveRecord::Migration[7.2]
  def change
    create_table :parameters do |t|
      t.string :code
      t.string :description
      t.string :value

      t.timestamps
    end

    add_index :parameters, :code, unique: true
  end
end
