#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
	test "should register a customer if this is the first interaction" do
		customer = Customer.find_by_phone_number("254722200200")
		assert customer.nil? 

		post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }

		customer = Customer.find_by_phone_number("254722200200")
		assert !customer.nil? 
	end

	test "Send welcome message after receipt of start word" do
		message = Message.first
		assert_nil message

		post :begin, { phone_number: "254722200200", name: "Trevor", text: "Dial-A-Delivery", notification_type: "MessageReceived" }

		message = Message.first
		assert_equal message.customer.phone_number, "254722200200"
		assert_equal message.text, "Hallo Trevor. Thank you for choosing Dial-a-Delivery. Please send us your surburb or share your location via whatsapp to get the contact details of your nearest Dial-a-Delivery location."
	end

	test "Ask for location via whatsapp after receipt of not start word" do
		post :begin, { phone_number: "254716085380", name: "Rachael", text: "Dial", notification_type: "MessageReceived" }
		
		message = Message.first

		assert_equal message.customer.phone_number, "254716085380"
		assert_equal message.text, "Sorry we do not yet recognize Dial as a Surburb. Please share your location via whatsapp."
	end

	test "It should return the closest outlet when a user sends their location" do
		post :begin, { phone_number: "254716085380", address: "Ngong road", name: "Rachael", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }
		message = Message.all[-2]
		assert_equal message.text, "Your nearest Dial-a-Delivery location near Ngong road is #{outlets(:ngong_road).name}. We are sending you their contacts shortly."
	end

	test "It should return a message that there is no close outlet if they are too far away" do
		post :begin, { phone_number: "254716085380", address: "Mombasa", name: "Rachael", notification_type: "LocationReceived", latitude: -4.0434771, longitude: 39.6682065 }
		
		message = Message.last
		assert_equal message.text, "Sorry Rachael we do not yet have an outlet near Mombasa."
	end

	test "It should detect a location from the text received if a user sends in the location as a word" do
		post :begin, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" }	

		message = Message.all[-2]
		assert_equal message.text, "Your nearest Dial-a-Delivery location near ihub is #{outlets(:ngong_road).name}. We are sending you their contacts shortly."
	end

	test "It should save an unknown location from text to an unapproved suburb" do
		post :begin, { phone_number: "254716085380", text: "Jogoo Rd", name: "Rachael", notification_type: "MessageReceived" }

		message = Message.last
		assert_equal message.text, "Sorry we do not yet recognize Jogoo Rd as a Surburb. Please share your location via whatsapp."

		jogoo_rd = Surburb.find_by(name: "Jogoo Rd", approved: false)
		assert_equal true, !jogoo_rd.nil?
		assert_equal false, jogoo_rd.approved
	end

	test "Send surburb yes but no outlet" do
		post :begin, { phone_number: "254716085380", text: "kayole", name: "Rachael", notification_type: "MessageReceived" }

		message = Message.last
		assert_equal message.text, "Sorry Rachael we do not yet have an outlet near kayole."

	end
	
	test "Customer must be unique" do
		Customer.delete_all
		assert_equal 0, Customer.count
		post :begin, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" }
		assert_equal 1, Customer.count
		post :begin, { phone_number: "254716085380", text: "Ihub", name: "Moses", notification_type: "MessageReceived" }
		assert_equal 1, Customer.count
	end
end