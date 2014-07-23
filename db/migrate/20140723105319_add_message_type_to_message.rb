class AddMessageTypeToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :message_type, :string
  end
end
