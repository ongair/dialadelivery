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
	def get_response text
		if Rails.env.production?
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'text' => text
			}

			url = URI.parse(ENV['API_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def response_vcard first_name, contact_number
		# if Rails.env.production?
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'first_name' => first_name,
				'contact_number' => contact_number
			}
			puts ">>>>>>>#{params}"
			url = URI.parse(ENV['API_VCARD_URL'])
			response = Net::HTTP.post_form(url, params)
		# end
	end

	def get_surburb text
		surburb = Surburb.where(Surburb.arel_table[:name].matches(text)).take
	end

	def return_location
		place = params[:address]
		location = Location.create! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		
		if outlet
			text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, place+' ')+' '+outlet.name
		else
			text = ENV['NO_OUTLET_MESSAGE'].gsub(/(?=\bwe\b)/, @customer.name+' ')+' '+place
		end

		response = get_response text
		if outlet
			send_vcard
		end
		message = Message.create! :customer => @customer, :text => text
	end

	def return_surburb surburb
		outlet = surburb.outlet
		text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, surburb.name+' ')+' '+outlet.name

		response = get_response text
		send_vcard
		message = Message.create! :customer=>@customer, :text=>text
	end

	def send_vcard
		location = Location.last
		outlet = Outlet.find_nearest location
		contact_number = []
		outlet.outlet_contacts.each do |number|
			contact_number.push number.phone_number
		end
		response = response_vcard outlet.name, contact_number
	end

	def wrong_query
		text = ENV['NO_SURBURB_MESSAGE'].gsub(/(?=\bPlease\b)/, @customer.name+'. ')
		response = get_response text
		message = Message.create! :text => text, :customer => @customer
	end

	def set_customer
		@customer = Customer.find_by_name_and_phone_number(params[:name], params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
			get_response ENV['WELCOME_MESSAGE']
		end
		@customer
	end
end