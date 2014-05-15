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
	has_many :orders
end
