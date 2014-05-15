# == Schema Information
#
# Table name: order_items
#
#  id         :integer          not null, primary key
#  pizza_id   :integer
#  size       :string(255)
#  quantity   :integer
#  price      :float
#  order_id   :integer
#  status     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OrderItem < ActiveRecord::Base
  belongs_to :pizza
  belongs_to :order
end
