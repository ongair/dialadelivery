require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]
	# before_action :set_outlet, only: [:return_location, :send_vcard]

	def begin
		if params[:notification_type] == "LocationReceived"
			return_location
		elsif params[:notification_type] == "MessageReceived"
			surburb = get_surburb params[:text]
			if surburb
				if surburb.approved
					return_surburb surburb
				else
					wrong_query
				end
			else
				Surburb.create :name=>params[:text], :approved=>false
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

	def response_vcard params
		if Rails.env.production?
			url = URI.parse(ENV['API_VCARD_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def get_surburb text
		surburb = Surburb.where(Surburb.arel_table[:name].matches(text)).take
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

		response = get_response params
		if outlet
			send_vcard params
		end
		message = Message.create! :customer => @customer
		if outlet
			message.text = "Your nearest Dial-A-Delivery location near #{place} is #{outlet.name}"
			message.save
		else
			message.text = "Sorry #{@customer.name} we do not yet have an outlet near #{place}"
			message.save
		end
	end

	def return_surburb surburb
		outlet = surburb.outlet

		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN'],
			'text' => "Your nearest Dial-A-Delivery location near #{surburb.name} is #{outlet.name}"
		}

		response = get_response params
		send_vcard params
		message = Message.create! :customer=>@customer, :text=>"Your nearest Dial-A-Delivery location near #{surburb.name} is #{outlet.name}"
	end

	def send_vcard params
		params.delete('text')
		params['first_name'] = "Dial-A-Delivery"
		params['contact_number'] = []

		location = Location.last
		outlet = Outlet.find_nearest location

		outlet.outlet_contacts.each do |contact_number|
			params['contact_number'].push contact_number.phone_number
		end

		response = response_vcard params
		
	end

	def wrong_query
		params = {
			'phone_number' => @customer.phone_number,
			'token' => ENV['TOKEN'],
			'text' => "Sorry #{@customer.name}. Please share your location via WhatsApp"
		}
		response = get_response params	
		message = Message.create! :text => "Sorry #{@customer.name}. Please share your location via WhatsApp", :customer => @customer
	end

	def set_customer
		@customer = Customer.find_by_phone_number(params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end
end