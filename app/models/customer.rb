# == Schema Information
#
# Table name: customers
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  phone_number :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Customer < ActiveRecord::Base
	has_many :locations
	has_many :orders
	has_many :messages
end
