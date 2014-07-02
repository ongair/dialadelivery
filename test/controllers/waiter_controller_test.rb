require 'test_helper'

class WaiterControllerTest < ActionController::TestCase
  

  test "Should register a customer if this is the first interaction" do
  	post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

  	@customer = Customer.find_by_phone_number("254722200200")
  	assert !@customer.nil?
  end

  test "Should create a new order for a customer if they text in wiht the start word" do
  	post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }
  	@customer = Customer.find_by_phone_number("254722200200")

  	@order = Order.find_by_customer_id(@customer.id)
  	assert_not_nil @order
  end
end
