class WaiterController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:order]
	@@can_proceed = false

	def order
		if params[:notification_type]=="LocationReceived"
			return_location
		elsif params[:notification_type]=="DeliveryReceipt"
			message = Message.find_by(external_id: params[:id])
			if params[:id] == message.external_id
				@@can_proceed = true
			end
		else params[:notification_type]=="MessageReceived"
			order = set_order
			if is_a_surburb? params[:text]
				surburb = get_surburb params[:text]
				if surburb.approved
					outlet = surburb.outlet
					if outlet
						text = get_outlet_text_for_order_location surburb.name, outlet.name
					else
						text = get_outlet_text_for_no_order_location surburb.name, @customer.name
					end
					send_message "text", text
					if outlet
						start_order outlet
					end
				else
					text = wrong_query params[:text]
					send_message "text", text
				end
			elsif @@can_proceed
				process_text params[:text]
				@@can_proceed = false
			elsif order.nil? || order.order_step=="order_completed" || order.order_step=="was_cancelled"
				Surburb.create :name=>text, :approved=>false
				send_text = wrong_query text
				send_message "text", send_text
			end

		end
		render json: { success: true }
	end

	private
	def send_message type, whatever, params={}
		case type
		when "text"
			@message = Message.create! :customer=>@customer, message_type: "text", text: whatever
		when "image"
			@message = Message.create! :customer=>@customer, message_type: "image", image: File.new(whatever, "r")
		when "contact"
			@message = Message.create! :customer=>@customer, message_type: "contact", firstname: whatever
		end
		@message.deliver params
	end

	def get_contact_array outlet
		contact_numbers = []
		outlet.outlet_contacts.each do |number|
			contact_numbers.push number.phone_number
		end
		contact_numbers
	end

	def is_a_surburb? text
		surburb = get_surburb text
		!surburb.nil?
	end

	def start_order outlet
		order = set_order
		if order.nil? || order.order_step == "order_completed" || order.order_step == "was_cancelled"
			order = Order.create! customer_id: @customer.id, order_step: "sent_menu"
		end
		reply order, outlet
	end

	def reply order, outlet
		contact_numbers = get_contact_array outlet
		send_message 'contact', outlet.name.gsub(',',''), :contacts=>contact_numbers
		send_menu
	end

	def send_menu
		path = Rails.root + 'app/assets/images/menu.jpg'
		send_message "image", path
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
		send_message "text", text
		if outlet
			start_order outlet
		end
	end

	def send_cancel_order_text
		cancel_order_text = "Your order has been cancelled."
		send_message "text", cancel_order_text
	end

	def set_order
		order = @customer.orders.last
	end

	def process_text text
		order = set_order
		text.downcase!
		if text == 'cancel'
			send_cancel_order_text
			order.order_step = "was_cancelled"
			order.save
		else
			case order.order_step
			when "sent_menu"
				text.delete!(' ')
				if is_a_main_order?(text)
					reply = "Great! You have made your order. Details are: "
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
					send_message "text", main_reply
					@@reply = reply.split(': ')[-1]
					order.order_step = "asked_for_free_option"
					order.save
				else
					wrong_main_order_format = get_wrong_main_order_format @customer.name
					send_message "text", wrong_main_order_format
				end

			when "asked_for_free_option"
				text.delete!(' ')
				if is_a_pizza_code? text[0]
					pizza_price = get_pizza_price(@@reply)
					main_order = get_main_order text[0], @@reply, @@num_size, pizza_price
					send_message "text", main_order
					order.order_step = "asked_for_confirmation"
					order.save
				else
					wrong_free_pizza_format = get_wrong_free_pizza_format @customer.name
					send_message "text", wrong_free_pizza_format
				end

			when "asked_for_confirmation"
				if text == "yes"
					final = get_order_question "order_complete"
					send_message "text", final
					order.order_step = "order_completed"
					order.save
				elsif text == "no"
					send_cancel_order_text
					order.order_step = "was_cancelled"
					order.save
				else
					wrong_confirmation = get_wrong_boolean_format @customer.name
					send_message "text", wrong_confirmation
				end
			when "order_completed"
				text = "Please send the word Pizza to start another order"
				send_message "text", text
			end
		end
	end

	def has_pending_orders?
		!@customer.orders.pending.empty?
	end

	def set_customer
		@customer = Customer.find_by_phone_number(params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
			text = ENV['WELCOME_MESSAGE'].gsub(/(?=\bThank\b)/, @customer.name+'. ')
			send_message "text", text
		end
		@customer
	end
end
