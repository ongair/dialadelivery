class AddFirstnameToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :firstname, :string
  end
end
