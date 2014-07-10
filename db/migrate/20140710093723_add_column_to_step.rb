class AddColumnToStep < ActiveRecord::Migration
  def change
    add_column :steps, :order_type, :string
  end
end
