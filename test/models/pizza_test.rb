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

require 'test_helper'

class PizzaTest < ActiveSupport::TestCase
  
  test "It can get the price based on the size of the Pizza" do
    
    hawaiian = pizzas(:hawaiian)
    assert_equal 800, hawaiian.get_price(ENV['SIZE_MEDIUM'])
    assert_equal 600, hawaiian.get_price(ENV['SIZE_REGULAR'])
    assert_equal 1000, hawaiian.get_price(ENV['SIZE_LARGE'])
  end
end
