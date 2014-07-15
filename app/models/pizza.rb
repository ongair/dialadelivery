# == Schema Information
#
# Table name: pizzas
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  medium_price :float
#  small_price  :float
#  large_price  :float
#  code         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Pizza < ActiveRecord::Base
	def get_price size
		if size.downcase == ENV['SIZE_SMALL'].downcase
			return small_price
		elsif size.downcase == ENV['SIZE_MEDIUM'].downcase
			return medium_price
		else
			return large_price
		end			
	end
end
