require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]
	# before_action :set_outlet, only: [:return_location, :send_vcard]

	def begin
		if params[:notification_type] == "LocationReceived"
			process_location
		elsif params[:notification_type] == "MessageReceived"
			if params[:text].downcase == ENV['BEGIN'].downcase
				send_message 'welcome'
			else
				surburb = get_surburb params[:text]
				if surburb
					if surburb.approved
						send_message 'location_and_outlet', surburb.name, surburb.outlet
					else
						send_message 'no_surburb', surburb.name
					end
				else
					Surburb.create :name=>params[:text], :approved=>false
					send_message 'no_surburb', params[:text]
				end
			end
		end
		render json: { success: true }
	end

	private

	def send_message text, place="", outlet="", params={}
		if text.downcase != 'contact'
			m = get_order_question text, place, outlet
			message = Message.create! text: m, message_type: 'text', customer: @customer
		else
			message = Message.create! customer: @customer, message_type: 'contact'
		end
		message.deliver params
	end

	def get_contact_array outlet
		contact_numbers = []
		outlet.outlet_contacts.each do |number|
			contact_numbers.push number.phone_number
		end
		contact_numbers
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
			url = URI.parse(ENV['API_VCARD_URL'])
			response = Net::HTTP.post_form(url, params)
		end
	end

	def get_surburb text
		surburb = Surburb.where(Surburb.arel_table[:name].matches(text)).take
	end

	def process_location
		location = Location.create! :name => params[:address], :latitude => params[:latitude], :longitude => params[:longitude], :customer => @customer
		outlet = Outlet.find_nearest location
		
		if outlet
			send_message 'location_and_outlet', params[:address], outlet
		else
			send_message 'location_no_outlet', params[:address]
		end
		if outlet
			contact_numbers = get_contact_array outlet
			send_message 'contact', contacts: contact_numbers
		end
	end

	# def return_surburb surburb
	# 	outlet = surburb.outlet
	# 	text = ENV['OUTLET_MESSAGE'].gsub(/(?=\bis\b)/, surburb.name+' ')+' '+outlet.name.gsub(',','')

	# 	get_response text
	# 	send_vcard outlet
	# 	Message.create! :customer=>@customer, :text=>text
	# end

	def send_vcard outlet
		contact_number = []
		outlet.outlet_contacts.each do |number|
			contact_number.push number.phone_number
		end
		response_vcard outlet.name.gsub(',',''), contact_number
	end

	def set_customer
		@customer = Customer.find_by_name_and_phone_number(params[:name], params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end
end