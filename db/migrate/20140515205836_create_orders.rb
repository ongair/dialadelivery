class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :customer, index: true
      t.references :outlet, index: true
      t.references :location, index: true
      t.string :status

      t.timestamps
    end
  end
end
