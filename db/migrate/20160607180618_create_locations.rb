class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :name
      t.text :address
      t.float :lat
      t.float :lng
      t.integer :user_id

      t.timestamps

    end
  end
end
