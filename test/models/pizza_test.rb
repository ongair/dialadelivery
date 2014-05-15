require 'test_helper'

class PizzaTest < ActiveSupport::TestCase
  
  test "It can get the price based on the size of the Pizza" do
    
    hawaiian = pizzas(:hawaiian)
    assert_equal 800, hawaiian.get_price(ENV['SIZE_MEDIUM'])
    assert_equal 600, hawaiian.get_price(ENV['SIZE_SMALL'])
    assert_equal 1000, hawaiian.get_price(ENV['SIZE_LARGE'])
  end
end
