class CreateOutletContacts < ActiveRecord::Migration
  def change
    create_table :outlet_contacts do |t|
      t.references :outlet, index: true
      t.string :phone_number
      t.integer :priority

      t.timestamps
    end
  end
end
