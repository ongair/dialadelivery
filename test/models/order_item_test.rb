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

require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
