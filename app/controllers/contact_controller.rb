require 'net/http'

class ContactController < ApplicationController
	skip_before_action :verify_authenticity_token 
	before_action :set_customer, only: [:begin, :ask_location]

	def begin
		puts ">>>>>> Params #{params}"
		if params[:location]
			return_location
		elsif params[:text]
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
			url = URI.parse(ENV['API_URL'])
			response = Net::HTTP.post_form(url, params)
		end

		def is_begin_word? text
			text.downcase == ENV['BEGIN'].downcase
		end

		def wrong_query
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'text' => "Sorry wrong query. Please send Dial-A-Delivery for delivery to your location"
			}
			get_response params			
		end

		def ask_location
			params = {
				'phone_number' => @customer.phone_number,
				'token' => ENV['TOKEN'],
				'text' => 'Thank you for choosing Dial-A-Delivery. Please share your location using WhatsApp..'
			}
			get_response params
		end

		def return_location
			#location code here
		end

		def set_customer
			@customer = Customer.find_by_phone_number(params[:phone_number])
			if @contact.nil?
				@customer = Customer.create! phone_number: params[:phone_number], name: params[:name]
			end
			@customer
		end
end