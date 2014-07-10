class AddApprovedToSurburb < ActiveRecord::Migration
  def change
    add_column :surburbs, :approved, :boolean
  end
end
