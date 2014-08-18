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
		if Rails.env.production?
			params = {
				'phone_number' => customer.phone_number,
				'token' => ENV['TOKEN'],
				'text' => text
			}
			url = ENV['API_URL']
			response = HTTParty.post(url,body: params, debug_output: $stdout)
		end
	end
end
