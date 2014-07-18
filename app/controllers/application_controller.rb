class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def is_a_pizza_code? code
  	(Pizza.pluck :code).map(&:downcase).include? code
  end

  def is_a_pizza_size? size
  	['r','m','l'].include? size
  end

  def is_a_main_order? text
    is_a_pizza_code?(text[-2]) && is_a_pizza_size?(text[-1])
  end

  def get_pizza_name code
  	pizza = Pizza.where(Pizza.arel_table[:code].matches(code)).take.name
  end

  def get_pizza_size size
  	sizes = {
  		'r' => 'Regular',
  		'm' => 'Medium',
  		'l' => 'Large'
  	}
  	sizes[size]
  end

  def get_order_question order_type
  	order_question = OrderQuestion.where(OrderQuestion.arel_table[:order_type].matches(order_type)).take.text
  end

  def get_pizza_price reply
  	reply = reply.split
  	if reply.length > 3
  		reply[1] = reply.slice(1..-2).join(' ')
  	end
  	pizza = Pizza.where(Pizza.arel_table[:name].matches(reply[1])).take
  	if reply[0] != "One"
  		pizza_price = pizza.get_price(reply[-1]) * reply[0].to_i
  	else
  		pizza_price = pizza.get_price(reply[-1])
  	end

  end

  def get_main_order text, reply, num_size, price
  	main_order = "Your order details are as below, please confirm. Main Order: "
  	main_order = main_order+reply
  	main_order = main_order+". "+"Free Pizza: "+num_size[0]+" "+get_pizza_name(text)+" "+num_size[1]
  	main_order = main_order+" at KES #{price}. Correct? (please reply with a yes or no)"
  end

  def get_wrong_main_order_format name
  	"Sorry #{name}. Wrong format of reply. Please start with a number then order code, either A, B, C or D then the size either S for Small, M for Medium or L for Large"
  end

  def get_wrong_free_pizza_format name
  	"Sorry #{name}. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"
  end

  def get_wrong_boolean_format name
  	"Sorry #{name}. Please send either yes or no to confirm or deny your order"
  end

  def get_outlet_text_for_order_location place, name
  	text = "Your order for #{place} will be sent to #{name}. "
    text = text+"We are sending you their contacts shortly "
    text = text+"and a menu from whose codes to pick your order.."
  end

  def get_outlet_text_for_no_order_location place, name
  	"Sorry #{name} we do not yet have an outlet near #{place}"
  end

  def get_surburb text
    surburb = Surburb.where(Surburb.arel_table[:name].matches(text)).take
  end

  def return_surburb_text surburb
    outlet = surburb.outlet
    text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, surburb.name+' ')+' '+outlet.name.gsub(',','')
    return outlet, text
  end

  def wrong_query
    text = ENV['NO_SURBURB_MESSAGE'].gsub(/(?=\bPlease\b)/, @customer.name+'. ')
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
        'first_name' => first_name
      }
      contact_number.each do |contact|
        index = contact_number.index contact
        params["contact_number[#{index}]"] = contact
      end
      url = URI.parse(ENV['API_VCARD_URL'])
      response = Net::HTTP.post_form(url, params)
    end
  end
end
