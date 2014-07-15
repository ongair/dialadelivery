class AddColumnToStep < ActiveRecord::Migration
  def change
    add_reference :steps, :customer, index: true
  end
end
