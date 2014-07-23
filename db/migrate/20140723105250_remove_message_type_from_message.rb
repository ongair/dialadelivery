class RemoveMessageTypeFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :message_type, :string
  end
end
