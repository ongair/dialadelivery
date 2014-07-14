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

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
    

end
