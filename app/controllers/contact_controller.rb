require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]
	# before_action :set_outlet, only: [:return_location, :send_vcard]

	def begin
		if params[:notification_type] == "LocationReceived"
			process_location params[:address], params[:latitude], params[:longitude]
		elsif params[:notification_type] == "MessageReceived"
			if params[:text].downcase == ENV['BEGIN'].downcase
				send_message 'welcome'
			else
				surburb = get_surburb params[:text]
				if surburb
					if surburb.approved
						if surburb.outlet
							send_message 'location_and_outlet', surburb.name, surburb.outlet
							contact_numbers = get_contact_array surburb.outlet
							send_message 'contact', "", "", contacts: contact_numbers, first_name: surburb.outlet.name.gsub(',','')
						else
							send_message 'location_no_outlet', surburb.name
						end
					else
						send_message 'no_surburb', surburb.name
					end
				else
					surburb = Surburb.create :name=>params[:text], :approved=>false
					coordinates = surburb.get_coordinates
					if coordinates
						surburb.approved = true
						surburb.save!
						process_location params[:text], coordinates[0], coordinates[1]
					else
						send_message 'no_surburb', params[:text]
					end
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

	def get_surburb text
		surburb = Surburb.where(Surburb.arel_table[:name].matches(text)).take
	end

	def process_location address, latitude, longitude
		location = Location.create! :name => address, :latitude => latitude, :longitude => longitude, :customer => @customer
		outlet = Outlet.find_nearest location
		if outlet
			surburb = Surburb.find_by(name: address)
			if surburb and surburb.outlet.nil?
				surburb.outlet = outlet
				surburb.save!
			end
			send_message 'location_and_outlet', address, outlet
			contact_numbers = get_contact_array outlet
			send_message 'contact', "", "", contacts: contact_numbers, first_name: outlet.name.gsub(',','')
		else
			send_message 'location_no_outlet', address
		end
	end

	def set_customer
		@customer = Customer.find_by(phone_number: params[:phone_number])
		if @customer.nil?
			@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
		end
		@customer
	end
end