# == Schema Information
#
# Table name: orders
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  outlet_id   :integer
#  location_id :integer
#  status      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Order < ActiveRecord::Base
  belongs_to :customer
  belongs_to :outlet
  belongs_to :location
end
