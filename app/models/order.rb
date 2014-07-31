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
		if string.length>2
			num = string[0..-3]
		else
			num = "1"
		end
		pizza_name = Pizza.get_pizza_row(string[-2]).name
		sizes = {
			'r' => 'Regular',
			'm' => 'Medium',
			'l' => 'Large'
		}
		pizza_size = sizes[string[-1].downcase]
		num+" "+pizza_name+" "+pizza_size
	end
end
