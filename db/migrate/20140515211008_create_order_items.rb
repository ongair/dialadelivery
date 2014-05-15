class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :pizza, index: true
      t.string :size
      t.integer :quantity
      t.float :price
      t.references :order, index: true
      t.string :status

      t.timestamps
    end
  end
end
