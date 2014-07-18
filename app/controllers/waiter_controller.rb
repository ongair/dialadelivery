class WaiterController < ApplicationController

	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:order]

	def order
		if params[:notification_type]=="MessageReceived"
			if is_start_word? params[:text]
				start_order
			elsif is_a_surburb? params[:text]
				surburb = get_surburb params[:text]
				if surburb.approved
					outlet = surburb.outlet
					if outlet
						text = get_outlet_text_for_order_location surburb.name, outlet.name
					else
						text = get_outlet_text_for_no_order_location surburb.name, @customer.name
					end
					get_response text
					if outlet
						send_vcard outlet
						send_menu
						order = set_order
						order.order_step = "sent_menu"
						order.save
					end
					Message.create! :customer=>@customer, :text=>text
				else
					text = wrong_query
					get_response text
					Message.create! :text => text, :customer => @customer
				end
			else
				process_text params[:text]
			end
		elsif params[:notification_type]=="LocationReceived"
			return_location
		end
		render json: { success: true }
	end

	private

	def is_a_surburb? text
		surburb = get_surburb text
		!surburb.nil?
	end

	def get_response text
		if Rails.env.production?
			url = URI.parse(ENV['API_URL'])
			response = HTTParty.post(url, body: { token: ENV['TOKEN'],  phone_number: @customer.phone_number, text: text, thread: true}, debug_output: $stdout)
		end
	end

	def get_image_response img
		if Rails.env.production?
			url = URI.parse(ENV['API_IMAGE_URL'])
			image_response = HTTMultiParty.post(url, body: { token: ENV['TOKEN'],  phone_number: @customer.phone_number, image: img, thread: true }, debug_output: $stdout)
		end
	end

	def start_order
		order = Order.create! customer_id: @customer.id, order_step: "sent_steps"
		reply order
	end

	def reply order
		order_details = get_order_question "steps_for_ordering"
		get_response order_details
		Message.create! :customer => @customer, :text => order_details

		path = Rails.root + 'app/assets/images/steps.jpg'
		img = File.new(path)
		get_image_response img
	end

	def send_menu
		path = Rails.root + 'app/assets/images/menu.jpg'
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
			send_menu
			order = set_order
			order.order_step = "sent_menu"
			order.save
		end
		Message.create! :customer => @customer, :text => text
	end

	def send_cancel_order_text
		cancel_order_text = "Your order has been cancelled."
		get_response cancel_order_text
		Message.create! :customer => @customer, :text => cancel_order_text
	end

	def set_order
		order = @customer.orders.last
	end

	def process_text text
		order = set_order
		text.downcase!
		text.delete!(' ')
		
		if text == 'cancel'
			send_cancel_order_text
			order.order_step = "was_cancelled"
			order.save
		else
			case order.order_step
			when "sent_steps"
				Surburb.create :name=>params[:text], :approved=>false
				send_text = wrong_query
				get_response send_text
				Message.create! :text => text, :customer => @customer

			when "sent_menu", "was_cancelled"
				if is_a_main_order?(text)
					reply = "Your order details: "
					if text[/\d/]
						reply = reply+text[0]+' '
						@@num_size = [text[0]]
					else
						reply = reply+'One '
						@@num_size = ['One']
					end
					size = get_pizza_size(text[-1])
					reply = reply+get_pizza_name(text[-2])+' '+size
					order_question = get_order_question "free_pizza"
					@@num_size.push size
					
					main_reply = reply+". "+order_question
					get_response main_reply
					@@reply = reply.split(': ')[-1]
					order.order_step = "asked_for_free_option"
					order.save
					Message.create! :customer => @customer, :text => main_reply
				else
					wrong_main_order_format = get_wrong_main_order_format @customer.name
					get_response wrong_main_order_format
					Message.create! customer: @customer, text: wrong_main_order_format
				end

			when "asked_for_free_option"
				if is_a_pizza_code? text[0]
					pizza_price = get_pizza_price(@@reply)
					main_order = get_main_order text[0], @@reply, @@num_size, pizza_price
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
					send_cancel_order_text
					order.order_step = "was_cancelled"
					order.save
				else
					wrong_confirmation = get_wrong_boolean_format @customer.name
					get_response wrong_confirmation
					Message.create! customer: @customer, text: wrong_confirmation					
				end
			when "order_completed"
				text = "Please send the word Pizza to start another order"
				get_response text
				Message.create! customer: @customer, text: text
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
