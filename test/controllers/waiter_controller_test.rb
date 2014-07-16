#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class WaiterControllerTest < ActionController::TestCase
  test "Should register a customer if this is the first interaction" do
  	post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

  	@customer = Customer.find_by_phone_number("254722200200")
  	assert_not_nil @customer
  end

  test "Should create a new order for a customer if they text in with the start word" do
  	post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }
  	@customer = Customer.find_by_phone_number("254722200200")

  	@order = Order.find_by_customer_id(@customer.id)
  	assert_not_nil @order
  end

  test "Should send the intoductory image after receipt of PIZZA" do
    response = post :order, { phone_number: "254716085380", name: "Rachael", text: "PIZZA", notification_type: "MessageReceived" }

    assert_equal response.code, "200"
  end

  test "It should return the closest outlet when a user sends their location if outlet exists" do
    response = post :order, { phone_number: "254716085380", address: "Ngong road", name: "Rachael", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }
    assert_equal response.code, "200"

    message = Message.last
    assert_equal message.text, "Your order for Ngong road will be sent to #{outlets(:ngong_road).name}"
  end

  test "It should return a message that there is no close outlet if they are too far away" do
    response = post :order, { phone_number: "254716085380", address: "Mombasa", name: "Rachael", notification_type: "LocationReceived", latitude: -4.0434771, longitude: 39.6682065 }

    message = Message.last
    assert_equal message.text, "Sorry Rachael we do not yet have an outlet near Mombasa"
  end

  test "Should return customer's main order details and ask what free pizza they want" do
    post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "5BL", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: 5 Four Seasons Large"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: 5 Four Seasons Large. Free Pizza: 5 Meat Deluxe Large at KES 5000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
  end

  test "Should return customer's main order details for order of one and ask what free pizza they want" do
    post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "BL", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: One Four Seasons Large"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
  end

  test "Should handle wrong customer input during ordering" do
    post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "5Cs", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: 5 Hawaiian Small"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Trevor. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: 5 Hawaiian Small. Free Pizza: 5 Meat Deluxe Small at KES 3000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
  end

  test "Should allow a customer to cancel an order at any time by sending the word cancel" do
    post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "5bm", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: 5 Four Seasons Medium"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Trevor. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "1bl", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: 1 Four Seasons Large"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"
  end

  test "It should detect a location from the text received if a user sends in the location as a word" do
    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 

    @message = Message.last
    assert_equal @message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}"
  end

  test "whole process with Surburb text" do
    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "PIZZA", notification_type: "MessageReceived" }
    assert_equal response.code, "200"

    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 
    @message = Message.last
    assert_equal @message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}"
    assert_equal response.code, "200"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "5bm", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: 5 Four Seasons Medium"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Trevor. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "bl", notification_type: "MessageReceived" }
    message = Message.all[-2]
    assert_equal message.text, "Your order details: One Four Seasons Large"
    message = Message.last
    assert_equal message.text, "What free Pizza would you like to have?"

    response = post :order, { phone_number: "254722200200", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"
  end

  test "It should return a message that there is no close outlet if they are too far away" do
    response = post :order, { phone_number: "254716085380", address: "Mombasa", name: "Rachael", notification_type: "LocationReceived", latitude: -4.0434771, longitude: 39.6682065 }
    
    @message = Message.last
    assert_equal @message.text, "Sorry Rachael we do not yet have an outlet near Mombasa"
  end
end
