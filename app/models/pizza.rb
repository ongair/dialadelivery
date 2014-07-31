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
		if size.downcase == ENV['SIZE_REGULAR'].downcase
			return small_price.to_i
		elsif size.downcase == ENV['SIZE_MEDIUM'].downcase
			return medium_price.to_i
		else
			return large_price.to_i
		end			
	end
	def self.get_pizza_row code
		Pizza.where(Pizza.arel_table[:code].matches(code)).take
	end
	def self.is_a_pizza_code? code
		(Pizza.pluck :code).map(&:downcase).include? code
	end
	def self.is_a_pizza_size? size
		['r','m','l'].include? size
	end
end
