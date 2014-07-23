# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  text         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  customer_id  :integer
#  message_type :string(255)
#  image        :binary
#

class Message < ActiveRecord::Base
	belongs_to :customer

	def deliver
		params = {
			'phone_number' => customer.phone_number,
			'token' => ENV['TOKEN'],
			'thread' => true
		}
		if Rails.env.production?
			case message_type
			when "text"
				params['text'] = text
				url_str = ENV['API_URL']+"/send"
				url = URI.parse(url_str)
				response = HTTParty.post(url, body: params, debug_output: $stdout)
			when "image"
				params['image'] = image
				url_str = ENV['API_URL']+"/send_image"
				url = URI.parse(url_str)
				response = HTTMultiParty.post(url, body: params, debug_output: $stdout)
			when "vcard"
				params['text'] = text
				url_str = ENV['API_URL']+"/send_contact"
				url = URI.parse(url_str)
				response = HTTParty.post(url, body: params, debug_output: $stdout)
			end
		end
	end
	# handle_asynchronously :deliver
end
