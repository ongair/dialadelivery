# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  text        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  customer_id :integer
#

class Message < ActiveRecord::Base
	belongs_to :customer

	def deliver
		params_config = {
			'phone_number' => customer.phone_number,
			'token' => ENV['TOKEN'],
			'thread' => true
		}
		# if Rails.env.production?
		case message_type
		when "text"
			params_config['text'] = text
			url = URI.parse(ENV['API_URL']+"/send")
			response = HTTParty.post(url, body: params_config, debug_output: $stdout)
		when "image"
			params['image'] = params[:image]
			url = URI.parse(ENV['API_URL']+"/send_image")
			response = HTTMultiParty.post(url, body: params, debug_output: $stdout)
		when "vcard"
			params['text'] = text
			url = URI.parse(ENV['API_URL']+"/send_contact")
			response = HTTParty.post(url, body: params, debug_output: $stdout)
		end
		# end
	end
	# handle_asynchronously :deliver
end
