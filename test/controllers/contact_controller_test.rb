#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
	 test "should register a customer if this is the first interaction or get the customer if not" do
	 	post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }

	 	@customer = Customer.find_by_phone_number("254722200200")
	 	assert !@customer.nil? 
	 end

	test "Should send message to customer after receipt of pass phrase" do
		response = post :begin, { phone_number: "254723140111", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }
		
		# assert_equal response.code, "200"
		@message = Message.last

		assert_equal @message.customer.phone_number, "254723140111"
		assert_equal @message.text, "Hi Trevor! Thank you for choosing Dial-A-Delivery. Please share your location using WhatsApp to get the contacts of your nearest outlet"
	end

	test "Should send sorry wrong query message to customer after receipt of not pass phrase" do
		response = post :begin, { phone_number: "254723140111", name: "Perci", text: "Dial", notification_type: "MessageReceived" }
		
		# assert_equal response.code, "200"
		@message = Message.last

		assert_equal @message.customer.phone_number, "254723140111"
		assert_equal @message.text, "Sorry Perci. Please send Dial-A-Delivery for delivery to your location"
	end

	# test "It should return the closest outlet when a user sends their location" do
	# 	response = post :begin, { phone_number: "254723140111", name: "Perci", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }
	# 	assert_equal response.code, "200"
	#end

end