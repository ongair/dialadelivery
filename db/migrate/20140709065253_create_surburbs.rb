class CreateSurburbs < ActiveRecord::Migration
  def change
    create_table :surburbs do |t|
      t.string :name
      t.references :outlet, index: true

      t.timestamps
    end
  end
end
