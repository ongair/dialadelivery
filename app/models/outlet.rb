# == Schema Information
#
# Table name: outlets
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  latitude   :float
#  longitude  :float
#  created_at :datetime
#  updated_at :datetime
#

class Outlet < ActiveRecord::Base
	has_many :outlet_contacts
	has_many :surburbs
	has_many :orders
	reverse_geocoded_by :latitude, :longitude

	def self.find_nearest location
		outlet = Outlet.near([location.latitude, location.longitude], 20, :units => :km).first
		return outlet
	end
end
