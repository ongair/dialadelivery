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
		url = URI.parse(ENV['API_URL'])
		response = HTTParty.post(url, body: { token: ENV['TOKEN'],  phone_number: customer.phone_number, text: text, thread: true}, debug_output: $stdout)
	end
	handle_asynchronously :deliver
end
