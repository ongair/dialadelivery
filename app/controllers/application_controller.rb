class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def is_a_main_order? text
    Pizza.is_a_pizza_code?(text[-2]) && Pizza.is_a_pizza_size?(text[-1])
  end

  def set_pizza_price order_item
    order_item.price = order_item.pizza.get_price(order_item.size) * order_item.quantity
    order_item.save!
  end

  def get_main_order text, first_order, order_item
    main_order = OrderQuestion.get_order_question "main_order"
    main_order = main_order.gsub(/(?=\bFree\b)/, first_order+". ")
    free_pizza = "#{order_item.quantity} "+Pizza.get_pizza_row(text).name+" "+order_item.size
    main_order = main_order.gsub(/(?=\bat\b)/, free_pizza+" ")
    main_order = main_order.gsub(/(?=\bCorrect\b)/, order_item.price.to_i.to_s+". ")
  end

  def get_wrong_main_order_format
    OrderQuestion.get_order_question "wrong_main_order"
  end

  def get_wrong_free_pizza_format
    OrderQuestion.get_order_question "wrong_free_pizza"
  end

  def get_wrong_boolean_format
    OrderQuestion.get_order_question "wrong_boolean"
  end

  def get_outlet_text_for_order_location place, name
    text = OrderQuestion.get_order_question "outlet_found"
    text = text.gsub(/(?=\bwill\b)/, place+" ")
    text = text.gsub(/(?=\bWe\b)/, name+". ")
  end

  def get_outlet_text_for_no_order_location place, name
    text = OrderQuestion.get_order_question "outlet_not_found"
    text = text.gsub(/(?=\bwe\b)/, name+" ")
    text = text+" #{place}"
  end

  def wrong_query place
    text = OrderQuestion.get_order_question "surburb_not_found"
    text = text.gsub(/(?=\bwe\b)/, @customer.name+'. ')
    text = text.gsub(/(?=\bas\b)/, place+" ")
  end

  def send_vcard outlet
    contact_number = []
    outlet.outlet_contacts.each do |number|
      contact_number.push number.phone_number
    end
    response_vcard outlet.name.gsub(',',''), contact_number
  end

  def response_vcard first_name, contact_number
    if Rails.env.production?
      params = {
        'phone_number' => @customer.phone_number,
        'token' => ENV['TOKEN'],
        'first_name' => first_name,
        'thread' => true
      }
      contact_number.each do |contact|
        index = contact_number.index contact
        params["contact_number[#{index}]"] = contact
      end
      url = URI.parse(ENV['API_VCARD_URL'])
      response = HTTParty.post(url, body: params, debug_output: $stdout)
    end
  end
end
