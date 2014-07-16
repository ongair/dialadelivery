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
#  order_step  :string(255)
#

class Order < ActiveRecord::Base
  belongs_to :customer
  belongs_to :outlet
  belongs_to :location
  has_many :order_items

  scope :pending, -> { where(status: "PENDING" ) }

  def self.get_order string
  end
end
