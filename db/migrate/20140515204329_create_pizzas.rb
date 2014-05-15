class CreatePizzas < ActiveRecord::Migration
  def change
    create_table :pizzas do |t|
      t.string :name
      t.float :medium_price
      t.float :small_price
      t.float :large_price
      t.string :code

      t.timestamps
    end
  end
end
