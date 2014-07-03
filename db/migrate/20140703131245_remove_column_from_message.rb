class RemoveColumnFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :customer_id_id, :integer
  end
end
