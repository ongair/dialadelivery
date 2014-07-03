class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.references :customer_id, index: true

      t.timestamps
    end
  end
end
