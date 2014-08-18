# == Schema Information
#
# Table name: messages
#
#  id                 :integer          not null, primary key
#  text               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  customer_id        :integer
#  message_type       :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  firstname          :string(255)
#  external_id        :integer
#  sent               :boolean
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
			case message_type
			when 'text'
				url = "#{ENV['API_URL']}/send"
				response = HTTParty.post(url,body: params, debug_output: $stdout)
			end
		end
	end
end
