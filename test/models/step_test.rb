# == Schema Information
#
# Table name: steps
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  order_type  :string(255)
#  customer_id :integer
#

require 'test_helper'

class StepTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
