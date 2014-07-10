class WaiterController < ApplicationController

	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:order]

	def order
		if params[:notification_type]=="MessageReceived"
			if has_pending_orders?
				process_text params[:text]
			elsif is_start_word? params[:text]
				start_order
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
		options = {
			'A' => 'Meat Deluxe',
			'B' => 'Four Seasons',
			'C' => 'Hawaiian',
			'D' => 'Peri-Peri Chicken'
		}
		sizes = {
			'S' => 'Small',
			'M' => 'Medium',
			'L' => 'Large'
		}
		if Step.nil?
			Step.create! :type=>"intro"
		end
		step_type = Step.last.step
		
		case step_type
		when text =~ /\D/
			if text.length == 3
				reply = "Your order details: "
				reply = reply + text[0] +' '+ options[text[1]]+' '+sizes[text[2]]
				response = get_response reply

				
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
