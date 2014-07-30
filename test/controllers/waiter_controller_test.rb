#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class WaiterControllerTest < ActionController::TestCase

    test "It should only respond to messages after the user has received the message" do
        post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }

        message = Message.where(message_type: 'text').last
        assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
        message.external_id = 5
        message.save!

        post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }


            
    end

  test "Should register a customer if this is the first interaction" do
  	post :order, { phone_number: "254716085380", name: "Trevor", text: "Jamuhuri", notification_type: "MessageReceived" }
  	@customer = Customer.find_by_phone_number("254716085380")
  	assert_not_nil @customer
  end

  test "Should create a new order for a customer if they text in with their Surburb or Location" do
  	post :order, { phone_number: "254716085380", name: "Trevor", text: "Jamuhuri", notification_type: "MessageReceived" }
  	@customer = Customer.find_by_phone_number("254716085380")

  	@order = Order.find_by_customer_id(@customer.id)
  	assert_not_nil @order
  end

  test "It should return the closest outlet when a user sends their location if outlet exists" do
    post :order, { phone_number: "254716085380", address: "Ngong road", name: "Rachael", notification_type: "LocationReceived", latitude: outlets(:ngong_road).latitude, longitude: outlets(:ngong_road).longitude }

    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for Ngong road will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
end

test "It should detect a location from the text received if a user sends in the location as a word" do
    post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 

    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
end

test "It should return a message that there is no close outlet if they are too far away" do
    post :order, { phone_number: "254716085380", address: "Mombasa", name: "Rachael", notification_type: "LocationReceived", latitude: -4.0434771, longitude: 39.6682065 }

    message = Message.last
    assert_equal message.text, "Sorry Rachael we do not yet have an outlet near Mombasa"
end

test "It should return a message that we don not recognize the Surburb if it's not yet in our System" do
    post :order, { phone_number: "254716085380", text: "City Stadium", name: "Rachael", notification_type: "MessageReceived"}

    message = Message.last
    assert_equal message.text, "Sorry Rachael. we do not yet recognize city stadium as a location. Please share your location via WhatsApp."
end

test "Should return customer's main order details and ask what free pizza they want" do
    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }
    post :order, { phone_number: "254716085380", name: "Trevor", text: "5BL", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Large. What free Pizza would you like to have?"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: 5 Four Seasons Large. Free Pizza: 5 Meat Deluxe Large at KES 5000. Correct? (please reply with a yes or no)"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
end

test "Should return customer's main order details for order of one and ask what free pizza they want" do
    post :order, { phone_number: "254716085380", name: "Trevor", text: "Jamuhuri", notification_type: "MessageReceived" }
    post :order, { phone_number: "254716085380", name: "Trevor", text: "BL", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: One Four Seasons Large. What free Pizza would you like to have?"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
end

test "Should handle wrong customer input during ordering" do
    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }

    post :order, { phone_number: "254716085380", name: "Trevor", text: "5Cr", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Hawaiian Regular. What free Pizza would you like to have?"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Trevor. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: 5 Hawaiian Regular. Free Pizza: 5 Meat Deluxe Regular at KES 3000. Correct? (please reply with a yes or no)"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
end

test "Should allow a customer to cancel an order at any time by sending the word cancel" do
    post :order, { phone_number: "254716085380", name: "Trevor", text: "IHUB", notification_type: "MessageReceived" }

    post :order, { phone_number: "254716085380", name: "Trevor", text: "5bm", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Medium. What free Pizza would you like to have?"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Trevor. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    post :order, { phone_number: "254716085380", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }
    post :order, { phone_number: "254716085380", name: "Trevor", text: "1bl", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 1 Four Seasons Large. What free Pizza would you like to have?"
end

test "whole process with Surburb text" do
    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 
    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
    assert_equal response.code, "200"

    response = post :order, { phone_number: "254716085380", name: "Muaad", text: "5bm", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Medium. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Cynthia", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Rachael. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }
    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "bl", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: One Four Seasons Large. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "A", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254716085380", name: "Nyako", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
end

test "whole process with Surburb text and free pizza with size" do
    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 
    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
    assert_equal response.code, "200"

    response = post :order, { phone_number: "254716085380", name: "Muaad", text: "5bm", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Medium. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Cynthia", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Rachael. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "b l", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: One Four Seasons Large. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "AL", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254716085380", name: "Nyako", text: "yes", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
end

test "whole process with no to main order" do
    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 
    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."
    assert_equal response.code, "200"

    response = post :order, { phone_number: "254716085380", name: "Muaad", text: "5bm", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Medium. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Cynthia", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Rachael. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    post :order, { phone_number: "254716085380", name: "Trevor", text: "ihub", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "b l", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: One Four Seasons Large. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "AL", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254716085380", name: "Nyako", text: "no", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."
end

test "whole process without start word" do
    response = post :order, { phone_number: "254716085380", text: "Ihub", name: "Rachael", notification_type: "MessageReceived" } 
    message = Message.where(message_type: 'text').last
    assert_equal message.text, "Your order for ihub will be sent to #{outlets(:ngong_road).name}. We are sending you their contacts shortly and a menu from which to pick your order.."

    assert_equal response.code, "200"

    response = post :order, { phone_number: "254716085380", name: "Muaad", text: "5bm", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: 5 Four Seasons Medium. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Cynthia", text: "x", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Sorry Rachael. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "Cancel", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."

    post :order, { phone_number: "254716085380", name: "Trevor", text: "jamuhuri", notification_type: "MessageReceived" }

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "b l", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Great! You have made your order. Details are: One Four Seasons Large. What free Pizza would you like to have?"

    response = post :order, { phone_number: "254716085380", name: "Trevor", text: "AL", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order details are as below, please confirm. Main Order: One Four Seasons Large. Free Pizza: One Meat Deluxe Large at KES 1000. Correct? (please reply with a yes or no)"

    response = post :order, { phone_number: "254716085380", name: "Nyako", text: "no", notification_type: "MessageReceived" }
    message = Message.last
    assert_equal message.text, "Your order has been cancelled."
end

test "Should return not recognized as a Surburb" do
    post :order, { phone_number: "254716085380", text: "Machakos", name: "Rachael", notification_type: "MessageReceived" } 
    message = Message.last
    assert_equal message.text, "Sorry Rachael. we do not yet recognize machakos as a location. Please share your location via WhatsApp."
end
end
