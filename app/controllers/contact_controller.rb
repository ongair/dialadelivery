require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]
	# before_action :set_outlet, only: [:return_location, :send_vcard]

	def begin
		if params[:notification_type] == "LocationReceived"
			return_location
		elsif params[:notification_type] == "MessageReceived"
			if is_begin_word? params[:text]
				ask_location
			else
				wrong_query
			end
		end
		render json: { success: true }
	end

	private
	def get_response params
		if Rails.env.production?
			url = URI.parse(ENV['API_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def is_begin_word? text
		text.downcase == ENV['BEGIN'].downcase
	end

	def wrong_query
		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN'],
			'text' => "Sorry #{@customer.name}. Please send Dial-A-Delivery for delivery to your location"
		}
		response = get_response params			
		message = Message.create! :text => "Sorry #{@customer.name}. Please send Dial-A-Delivery for delivery to your location", :customer => @customer

	end

	def ask_location
		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN'],
			'text' => "Hi #{@customer.name}! Thank you for choosing Dial-A-Delivery. Please share your location using WhatsApp to get the contacts of your nearest outlet"
		}
		response = get_response params
		message = Message.create! :text => "Hi #{@customer.name}! Thank you for choosing Dial-A-Delivery. Please share your location using WhatsApp to get the contacts of your nearest outlet", :customer => @customer

	end

	def return_location
		place = params[:address]
		location = Location.create! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN']
		}

		if outlet
			params['text'] = "Your nearest Dial-A-Delivery location near #{place} is #{outlet.name}"
		else
			params['text'] = "Sorry #{@customer.name} we do not yet have an outlet near #{place}"
		end

		get_response params
		message = Message.create! :customer => @customer
		if outlet
			message.text = "Your nearest Dial-A-Delivery location near #{place} is #{outlet.name}"
			message.save
			send_vcard params
		else
			message.text = "Sorry #{@customer.name} we do not yet have an outlet near #{place}"
			message.save
		end
	end

	def send_vcard params
		puts ">>>>>>#{params}"
		params.delete('text')
		puts ">>>>>>#{params}"
		params['contact_number'] = {}

		count = 0

		location = Location.last
		outlet = Outlet.find_nearest location

		outlet.outlet_contacts.each do |contact_number|
			params['contact_number'][count] = contact_number
			count = count + 1
		end
		response = get_response params
	end

	def set_customer
		@customer = Customer.find_by_phone_number(params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end

	# def set_outlet
	# 	location = Location.create! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
	# 	@outlet = Outlet.find_nearest location
	# end
end