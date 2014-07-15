class RemoveColumnFromStep < ActiveRecord::Migration
  def change
    remove_column :steps, :type, :string
  end
end
