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

	has_attached_file :image
	validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	def deliver params={}
		params_config = {
			'phone_number' => customer.phone_number,
			'token' => ENV['TOKEN'],
			'thread' => true
		}
		if Rails.env.production?
			sent = false
			external_id = nil
			case message_type
			when "text"
				params_config['text'] = text
				url = "#{ENV['API_URL']}/send"
				response = HTTParty.post(url, body: params_config, debug_output: $stdout)
				sent = response.parsed_response["sent"]
				external_id = response.parsed_response["id"]
			when "image"
				# image_url = "#{ENV['BASE_URL']}#{image.url}"
				# image_url = "#{ENV['BASE_URL']}/app/assets/images/menu.jpg"
				path = Rails.root + 'app/assets/images/menu.jpg'
				image_for_sending = File.new(path, "r")
				params_config['image'] = image_for_sending
				url = "#{ENV['API_URL']}/send_image"
				response = HTTMultiParty.post(url, body: params_config, debug_output: $stdout)
				sent = response.parsed_response["sent"]
				external_id = response.parsed_response["id"]
			when "contact"
				params_config['first_name'] = firstname
				contacts = params[:contacts]
				contacts.each do |contact|
					index = contacts.index contact
					params_config["contact_number[#{index}]"] = contact
				end
				url = "#{ENV['API_URL']}/send_contact"
				response = HTTParty.post(url, body: params_config, debug_output: $stdout)
				sent = response.parsed_response["sent"]
				external_id = response.parsed_response["id"]
			end
			m = Message.find(id)
			m.sent = sent
			m.external_id = external_id
			m.save!
		end
	end
	# handle_asynchronously :deliver
end
