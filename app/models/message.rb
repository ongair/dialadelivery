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
#

class Message < ActiveRecord::Base
	belongs_to :customer

	has_attached_file :image
	validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	def deliver
		params = {
			'phone_number' => customer.phone_number,
			'token' => ENV['TOKEN'],
			'thread' => true
		}
		# if Rails.env.production?
			case message_type
			when "text"
				params['text'] = text
				url = "#{ENV['API_URL']}/send"
				response = HTTParty.post(url, body: params, debug_output: $stdout)
			when "image"
				params['image'] = image
				url = "#{ENV['API_URL']}/send_image"
				response = HTTMultiParty.post(url, body: params, debug_output: $stdout)
			when "vcard"
				params['text'] = text
				url = "#{ENV['API_URL']}/send_contact"
				response = HTTParty.post(url, body: params, debug_output: $stdout)
			end
		# end
	end
	# handle_asynchronously :deliver
end
