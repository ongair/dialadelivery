class CreateOrderQuestions < ActiveRecord::Migration
  def change
    create_table :order_questions do |t|
      t.string :order_type
      t.string :text

      t.timestamps
    end
  end
end
