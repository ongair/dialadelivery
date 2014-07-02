require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]

	def begin
		if is_begin_word? params[:text]
			ask_location
		end
		render json: { success: true }
	end

	private
		def is_begin_word? text
			text.downcase == ENV['BEGIN'].downcase
		end
		def ask_location
			url = URI.parse(ENV['API_URL'])
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'text' => 'Thank you for choosing Dial-A-Delivery.\n
							Please share your location using WhatsApp..'
			}
			response = Net::HTTP.post_form(url, params)
		end
		def set_customer
			@customer = Customer.find_by_phone_number(params[:phone_number])
			if @contact.nil?
				@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
			end
			@customer
		end
end