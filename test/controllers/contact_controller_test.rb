#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
	test "should register a customer if this is the first interaction or get the customer if not" do
		post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }

		@customer = Customer.find_by_phone_number("254722200200")
		assert !@customer.nil? 
	end

	test "Should send message to customer after receipt of pass phrase" do
		response = post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }
		
		assert_equal response.code, "200"
	end

	test "Should send sorry wrong query message to customer after receipt of not pass phrase" do
		response = post :begin, { phone_number: "254723140111", name: "Perci", text: "Dial", notification_type: "MessageReceived" }
		
		assert_equal response.code, "200"
	end
end