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

	def deliver params={}
		params_config = {
			'phone_number' => customer.phone_number,
			'token' => ENV['TOKEN'],
			'thread' => true
		}
		if Rails.env.production?
			case message_type
			when "text"
				params_config['text'] = text
				url = "#{ENV['API_URL']}/send"
				response = HTTParty.post(url, body: params_config, debug_output: $stdout)
			when "image"
				# image_url = "#{ENV['BASE_URL']}#{image.url}"
				# image_url = "#{ENV['BASE_URL']}/app/assets/images/menu.jpg"
				params_config['image'] = image
				url = "#{ENV['API_URL']}/send_image"
				response = HTTMultiParty.post(url, body: params_config, debug_output: $stdout)
			when "contact"
				params_config['first_name'] = firstname
				contacts = params[:contacts]
				contacts.each do |contact|
					index = contacts.index contact
					params_config["contact_number[#{index}]"] = contact
				end
				url = "#{ENV['API_URL']}/send_contact"
				response = HTTParty.post(url, body: params_config, debug_output: $stdout)
			end
		end
	end
	# handle_asynchronously :deliver
end
