require 'test_helper'

class OutletTest < ActiveSupport::TestCase
  
  test "It returns nil if there is no location within 20 km" do    
    location = locations(:alaska)
    closest = Outlet.find_nearest location
    assert_equal nil, closest
  end

  test "It returns the closest location if there is more than one location within 20 km" do    
    office = locations(:office)
    junction = outlets(:junction)
    closest = Outlet.find_nearest office
    assert_equal junction, closest
  end

end
