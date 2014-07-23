class AddImageToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :image, :binary
  end
end
