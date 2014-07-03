class AddColumnToMessage < ActiveRecord::Migration
  def change
    add_reference :messages, :customer, index: true
  end
end
