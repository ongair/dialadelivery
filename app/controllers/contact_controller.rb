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
					outlet, text = return_surburb_text surburb
					get_response text
					send_vcard outlet
					Message.create! :customer=>@customer, :text=>text
				else
					text = wrong_query params[:text]
					get_response text
					Message.create! :text => text, :customer => @customer
				end
			else
				Surburb.create :name=>params[:text], :approved=>false
				text = wrong_query params[:text]
				get_response text
				Message.create! :text => text, :customer => @customer
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

	def return_location
		place = params[:address]
		location = Location.create! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		
		if outlet
			text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, place+' ')+' '+outlet.name.gsub(',','')
		else
			text = ENV['NO_OUTLET_MESSAGE'].gsub(/(?=\bwe\b)/, @customer.name+' ')+' '+place
		end

		get_response text
		if outlet
			send_vcard outlet
		end
		Message.create! :customer => @customer, :text => text
	end

	def set_customer
		@customer = Customer.find_by_name_and_phone_number(params[:name], params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
			text = ENV['WELCOME_MESSAGE'].gsub(/(?=\bThank\b)/, @customer.name+'. ')
			get_response text
			Message.create! :text=>text, :customer=>@customer
		end
		@customer
	end
end