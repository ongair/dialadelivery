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
		order = Order.create! customer_id: @customer.id
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

	def process_text text
		text.downcase!
		options = {
			'a' => 'Meat Deluxe',
			'b' => 'Four Seasons',
			'c' => 'Hawaiian',
			'd' => 'Peri-Peri Chicken'
		}
		sizes = {
			's' => 'Small',
			'm' => 'Medium',
			'l' => 'Large'
		}
		if Step.all.count == 0
			Step.create! :type=>"order"
		end
		step = Step.last
		case step.type
		when "order"
			if  !options[text[1]].nil? && !sizes[text[2]].nil?
				reply = "Your order details: "
				if text.length == 3 && text =~ /\D/
					reply = reply + text[0] +' '+ options[text[1]]+' '+sizes[text[2]]
					get_response reply
					Message.create! :customer => @customer, :text => reply
					num_size = [text[0]]
					get_response "What free Pizza would you like to have?"
					message = Message.create! :customer => @customer, :text => "What free Pizza would you like to have?"
					step.type = "free"
					step.save
				else
					reply = reply +'One '+ options[text[1]]+' '+sizes[text[2]]
					get_response reply
					Message.create! :customer => @customer, :text => reply
					num_size = ["One"]
					get_response "What free Pizza would you like to have?"
					Message.create! :customer => @customer, :text => "What free Pizza would you like to have?"
					step.type = "free"
					step.save
				end
				num_size.push sizes[text[2]]
			else
				get_response "Sorry your entry is in wrong format."
				Message.create! :customer => @customer, :text => "Sorry your entry is in wrong format."
			end
		when "free"
			if text.length==1 && !options[text].nil?
				main_order = "Your order details are as below, please confirm. "
				main_order = main_order +"Main Order: "+ reply
				main_order = main_order +"Free Pizza :"+num_size[0]+" "+options[[text]]+" "+num_size[1]
				main_order = main_order+"Correct? (please reply with a yes or no)"
				get_response main_order
				Message.create! :customer => @customer, :text => main_order
			else
				get_response "Sorry your entry is in wrong format."
				Message.create! :customer => @customer, :text => "Sorry your entry is in wrong format."
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
		if @contact.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end
end
