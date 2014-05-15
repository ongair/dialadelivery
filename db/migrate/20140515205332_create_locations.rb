class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :customer, index: true
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :description

      t.timestamps
    end
  end
end
