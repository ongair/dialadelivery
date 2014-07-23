class RemoveImageFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :image, :binary
  end
end
