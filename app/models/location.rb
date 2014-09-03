# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  message_id :integer
#  preview    :text
#  latitude   :float
#  longitude  :float
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer
#
class Location < ActiveRecord::Base
	belongs_to :customer
end
