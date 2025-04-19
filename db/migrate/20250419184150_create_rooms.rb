class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.decimal :price_per_hour, null: false, precision: 10, scale: 2
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :rooms, :name, unique: true
  end
end
