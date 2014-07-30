class AddCanProceedToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :can_proceed, :boolean
  end
end
