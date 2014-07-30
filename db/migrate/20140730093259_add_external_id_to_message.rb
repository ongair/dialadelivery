class AddExternalIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :external_id, :integer
  end
end
