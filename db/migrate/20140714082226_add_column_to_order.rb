class AddColumnToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :order_step, :string
  end
end
