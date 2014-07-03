# == Schema Information
#
# Table name: outlet_contacts
#
#  id           :integer          not null, primary key
#  outlet_id    :integer
#  phone_number :string(255)
#  priority     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'test_helper'

class OutletContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
