class WaiterController < ApplicationController

	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:order]

	def order
		if params[:notification_type]=="MessageReceived"
			if is_start_word? params[:text]
				start_order
			else
				process_text params[:text]
			end
		elsif params[:notification_type]=="LocationReceived"
			return_location
		end
		render json: { success: true }
	end

	private

	def get_response text
		if Rails.env.production?
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
			}
			params['text'] = text
			url = URI.parse(ENV['API_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def get_image_response img
		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN'],
		}
		params['image'] = img
		if Rails.env.production?
			url = URI.parse(ENV['API_IMAGE_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def start_order
		order = Order.create! customer_id: @customer.id order_step: "sent_menu"
		reply order
	end

	def reply order
		get_image_response 'assets/intro.img'
	end

	def return_location
		place = params[:address]
		location = Location.find_or_create_by! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		if outlet
			text = "Your order for #{place} will be sent to #{outlet.name}"
		else
			text = "Sorry #{@customer.name} we do not yet have an outlet near #{place}"
		end
		response = get_response text
		if outlet
			get_image_response 'assets/menu.img'
		end
		message = Message.create! :customer => @customer, :text => text
	end

	def cancel_order
		cancel_order_text = "Your order has been cancelled."
		get_response cancel_order_text
		Message.create! :customer => @customer, :text => cancel_order_text
	end

	def process_text text
		text.downcase!
		step = @customer.orders.last
		if text == 'cancel'
			cancel_order
			step.order_step = "was_cancelled"
			step.save
		else
			case step.order_step
			when "sent_menu"
				if is_a_main_order?(text)
					reply = "Your order details: "
					if text =~ /\D/
						reply = reply+text[0]+' '
						@num_size = [text[0]]
					else
						reply = reply+'One '
						@num_size = ['One']
					end
					size = get_pizza_size text[2]
					reply+get_pizza_name text[1]+' '+size
					@num_size.push size
					
					get_response reply
					Message.create! :customer => @customer, :text => reply
					@reply = reply.split(':')[-1]
					
					get_response "What free Pizza would you like to have?"
					Message.create! :customer => @customer, :text => "What free Pizza would you like to have?"

					step.order_step = "asked_for_free_option"
					step.save
				else
					wrong_main_order_format = "Sorry #{@customer.name}. Wrong format of reply. Please start with a number then order code, either A, B, C or D then the size either S for Small, M for Medium or L for Large"
					get_response wrong_format
					Message.create! customer: @customer, text: wrong_format
				end

			when "asked_for_free_option"
				if is_a_pizza_code? text
					main_order = "Your order details are as below, please confirm. Main Order:  "
					main_order = main_order+@reply
					main_order = main_order+". "+"Free Pizza: "+@num_size[0]+" "+get_pizza_name text[1]+" "+@num_size[1]
					main_order = main_order+". Correct? (please reply with a yes or no)"

					get_response main_order
					Message.create! :customer => @customer, :text => main_order
					step.order_type = "asked_for_confirmation"
					step.save
				else
					wrong_free_pizza_format = "Sorry #{@customer.name}. Wrong format of reply. Please send either an A, B, C or D depending on the code of the pizza you want"
					get_response wrong_free_pizza_format
					Message.create customer: @customer, text: wrong_free_pizza_format
				end

			when "asked_for_confirmation"
				if text == "yes"
					final = "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then."
					get_response final
					Message.create! customer: @customer, text: final
				elsif text == "no"
					cancel_order
					step.order_step = "was_cancelled"
					step.save
				else
					wrong_confirmation = "Sorry #{@customer.name}. Please send either yes or no to confirm or deny your order"
					get_response wrong_confirmation
					Message.create! customer: @customer, text: wrong_confirmation					
				end
			end
		end
	end

	# def process_text text
	# 	text.downcase!
	# 	options = {
	# 		'a' => 'Meat Deluxe',
	# 		'b' => 'Four Seasons',
	# 		'c' => 'Hawaiian',
	# 		'd' => 'Peri-Peri Chicken'
	# 	}
	# 	sizes = {
	# 		's' => 'Small',
	# 		'm' => 'Medium',
	# 		'l' => 'Large'
	# 	}

	# 	step = Step.find_by_customer_id @customer.id
	# 	if step.nil?
	# 		step = Step.create! :order_type=>"order", :customer=>@customer
	# 	end
	# 	# if step.order_type.nil?
	# 	# 	step.order_type = "order"
	# 	# 	step.save
	# 	# end
	# 	if text == 'cancel'
	# 		get_response "Your order has been cancelled."
	# 		Message.create! :customer => @customer, :text => "Your order has been cancelled."
	# 		step.delete
	# 	else
	# 		case step.order_type
	# 		when "order"
	# 			if  !options[text[1]].nil? && !sizes[text[2]].nil?
	# 				reply = "Your order details: "
	# 				if text.length == 3 && 
	# 					reply = reply + text[0] +' '+ options[text[1]]+' '+sizes[text[2]]
	# 					get_response reply
	# 					@reply = text[0] +' '+ options[text[1]]+' '+sizes[text[2]]
	# 					Message.create! :customer => @customer, :text => reply
	# 					@num_size = [text[0]]
	# 					get_response "What free Pizza would you like to have?"
	# 					message = Message.create! :customer => @customer, :text => "What free Pizza would you like to have?"
	# 					step.order_type = "free"
	# 					step.save
	# 				else
	# 					reply = reply +'One '+ options[text[1]]+' '+sizes[text[2]]
	# 					get_response reply
	# 					@reply = 'One '+ options[text[1]]+' '+sizes[text[2]]
	# 					Message.create! :customer => @customer, :text => reply
	# 					@num_size = ["One"]
	# 					get_response "What free Pizza would you like to have?"
	# 					Message.create! :customer => @customer, :text => "What free Pizza would you like to have?"
	# 					step.order_type = "free"
	# 					step.save
	# 				end
	# 				@num_size.push sizes[text[2]]
	# 			else
	# 				get_response "Sorry your entry is in wrong format. Does not contain a digit and two letters"
	# 				Message.create! :customer => @customer, :text => "Sorry your entry is in wrong format. Does not contain a digit and two letters"
	# 			end
	# 		when "free"
	# 			if text.length==1 && !options[text].nil?
	# 				main_order = "Your order details are as below, please confirm. "
	# 				main_order = main_order+"Main Order: "+@reply
	# 				main_order = main_order+". "+"Free Pizza: "+@num_size[0]+" "+options[text]+" "+@num_size[1]
	# 				main_order = main_order+". Correct? (please reply with a yes or no)"
	# 				get_response main_order
	# 				Message.create! :customer => @customer, :text => main_order
	# 				step.order_type = "boolean"
	# 				step.save
	# 			else
	# 				get_response "Sorry wrong choice. Enter A,B,C or D"
	# 				Message.create! :customer => @customer, :text => "Sorry wrong choice. Enter A,B,C or D"
	# 			end
	# 		when "boolean"
	# 			if text == "yes"
	# 				final = "Thank you for ordering with Dial-a-Delivery, your pizza should be ready in 45 minutes, we hope you will be hungry by then :)"
	# 			else
	# 				final = "Your order has been cancelled"
	# 			end
	# 			get_response final
	# 			Message.create! :customer => @customer, :text => final
	# 			step.delete
	# 		end
	# 	end
	# end

	def is_start_word? text
		text.downcase == ENV['START'].downcase
	end

	def has_pending_orders?
		!@customer.orders.pending.empty?
	end

	def set_customer
		@customer = Customer.find_by_phone_number(params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end
end
