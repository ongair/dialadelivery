#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
	 test "should register a customer if this is the first interaction or get the customer if not" do
	 	post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }

	 	@customer = Customer.find_by_phone_number("254722200200")
	 	assert !@customer.nil? 
	 end

	# test "Should send message to customer after receipt of pass phrase which should be case insensitive" do
	# 	response = post :begin, { phone_number: "254716085380", name: "Trevor", text: "Dial-a-delivery", notification_type: "MessageReceived" }
		
	# 	# assert_equal response.code, "200"
	# 	@message = Message.last

	# 	assert_equal @message.customer.phone_number, "254716085380"
	# 	assert_equal @message.text, "Hi Trevor! Thank you for choosing Dial-A-Delivery. Please share your location using WhatsApp to get the contacts of your nearest outlet"
	# end

	test "Should send sorry wrong query message to customer after receipt of not pass phrase" do
		response = post :begin, { phone_number: "254716085380", name: "Rachael", text: "Dial", notification_type: "MessageReceived" }
		
		# assert_equal response.code, "200"
		@message = Message.last

		assert_equal @message.customer.phone_number, "254716085380"
		assert_equal @message.text, "Sorry Rachael. Please send a valid location name for delivery to where you are"
	end

	test "It should return the closest outlet when a user sends their location" do
		response = post :begin, { phone_number: "254716085380", address: "Ngong road", name: "Rachael", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }
	# 	assert_equal response.code, "200"

		@message = Message.last
		assert_equal @message.text, "Your nearest Dial-A-Delivery location near Ngong road is #{outlets(:ngong_road).name}"
	end

	test "It should return a message that there is no close outlet if they are too far away" do
		response = post :begin, { phone_number: "254716085380", address: "Mombasa", name: "Rachael", notification_type: "LocationReceived", latitude: -4.0434771, longitude: 39.6682065 }
		
		@message = Message.last
		assert_equal @message.text, "Sorry Rachael we do not yet have an outlet near Mombasa"
	end

	test "It should send a message with the contact details of the nearest outlet" do
		response = post :begin, { phone_number: "254716085380", address: "Ngong road", name: "Rachael", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }
	
		assert_equal response.code, "200"
	end

	test "It should detect a location from the text received if a user sends in the location as a word" do
		response = post :begin, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" }	

		@message = Message.last
		assert_equal @message.text, "Your nearest Dial-A-Delivery location near ihub is #{outlets(:ngong_road).name}"
	end
end