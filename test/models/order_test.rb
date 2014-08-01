# == Schema Information
#
# Table name: orders
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  outlet_id   :integer
#  location_id :integer
#  status      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  order_step  :string(255)
#

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
	test "Should get the correct number of pizzas" do  	
		str = "2BL"
		result = Order.get_order str

		assert_equal "2 Four Seasons Large", result

		str = "BL"
		result2 = Order.get_order str

		assert_equal "1 Four Seasons Large", result2
	end
end
