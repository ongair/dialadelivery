class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :type

      t.timestamps
    end
  end
end
