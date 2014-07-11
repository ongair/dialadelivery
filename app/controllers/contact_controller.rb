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
		if Rails.env.production?
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'first_name' => first_name
			}
			contact_number.each do |contact|
				index = contact_number.index contact
				params["contact_number[#{index}]"] = contact
			end
			puts ">>>>>>>>>>#{params}"
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

	def return_surburb surburb
		outlet = surburb.outlet
		text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, surburb.name+' ')+' '+outlet.name.gsub(',','')

		get_response text
		send_vcard outlet
		Message.create! :customer=>@customer, :text=>text
	end

	def send_vcard outlet
		contact_number = []
		outlet.outlet_contacts.each do |number|
			contact_number.push number.phone_number
		end
		response_vcard outlet.name.gsub(',',''), contact_number
	end

	def wrong_query
		text = ENV['NO_SURBURB_MESSAGE'].gsub(/(?=\bPlease\b)/, @customer.name+'. ')
		get_response text
		Message.create! :text => text, :customer => @customer
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