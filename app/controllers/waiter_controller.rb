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
			# params = {
			# 	'phone_number' => @customer.phone_number,
			# 	'token' => ENV['TOKEN'],
			# 	'text' => text
			# }
			url = URI.parse(ENV['API_URL'])
			# response = Net::HTTP.post_form(url, params)
			response = HTTParty.post(url, body: { token: ENV['TOKEN'],  phone_number: @customer.phone_number, text: text}, debug_output: $stdout)

		end
	end

	def get_image_response img
		# params = {
		# 	'phone_number' => @customer.phone_number,
		# 	'token' => ENV['TOKEN'],
		# 	'image' => img
		# }
		url = URI.parse(ENV['API_IMAGE_URL'])
		# response = Net::HTTP.post_form(url, params)
		image_response = HTTParty.post(url, body: { token: ENV['TOKEN'],  phone_number: @customer.phone_number, image: img, thread: true }, debug_output: $stdout)
	end

	def start_order
		order = Order.create! customer_id: @customer.id, order_step: "sent_menu"
		reply order
	end

	def reply order
		path = File.dirname(__FILE__)+'/../assets/images/steps.jpg'
		img = File.new(path)
		get_image_response img
	end

	def return_location
		place = params[:address]
		location = Location.find_or_create_by! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		if outlet
			text = get_outlet_text_for_order_location place, outlet.name
		else
			text = get_outlet_text_for_no_order_location place, @customer.name
		end
		response = get_response text
		if outlet
			path = File.dirname(__FILE__)+'/../assets/images/menu.jpg'
			img = File.new(path)
			get_image_response img
		end
		message = Message.create! :customer => @customer, :text => text
	end

	def cancel_order
		cancel_order_text = "Your order has been cancelled."
		get_response cancel_order_text
		Message.create! :customer => @customer, :text => cancel_order_text
	end

	def set_order
		order = @customer.orders.last
		if order.nil? || order.order_step == "was_cancelled"
			Order.create! customer_id: @customer.id, order_step: "sent_menu"
			order = @customer.orders.last
		end
		order
	end

	def process_text text
		text.downcase!
		order = set_order
		if text == 'cancel'
			cancel_order
			order.order_step = "was_cancelled"
			order.save
		else
			case order.order_step
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
					reply = reply+get_pizza_name(text[1])+' '+size
					@num_size.push size
					
					get_response reply
					Message.create! :customer => @customer, :text => reply
					@reply = reply.split(': ')[-1]
					
					order_question = get_order_question "free_pizza"
					get_response order_question
					Message.create! :customer => @customer, :text => order_question

					order.order_step = "asked_for_free_option"
					order.save
				else
					wrong_main_order_format = get_wrong_main_order_format @customer.name
					get_response wrong_main_order_format
					Message.create! customer: @customer, text: wrong_main_order_format
				end

			when "asked_for_free_option"
				if is_a_pizza_code? text

					pizza_price = get_pizza_price(@reply).to_i

					main_order = get_main_order text, @reply, @num_size, pizza_price
					get_response main_order
					Message.create! :customer => @customer, :text => main_order
					order.order_step = "asked_for_confirmation"
					order.save
				else
					wrong_free_pizza_format = get_wrong_free_pizza_format @customer.name
					get_response wrong_free_pizza_format
					Message.create customer: @customer, text: wrong_free_pizza_format
				end

			when "asked_for_confirmation"
				if text == "yes"
					final = get_order_question "order_complete"
					get_response final
					Message.create! customer: @customer, text: final
					order.order_step = "order_completed"
					order.save
				elsif text == "no"
					cancel_order
					order.order_step = "was_cancelled"
					order.save
				else
					wrong_confirmation = get_wrong_boolean_format @customer.name
					get_response wrong_confirmation
					Message.create! customer: @customer, text: wrong_confirmation					
				end
			end
		end
	end

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
