# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  text         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  customer_id  :integer
#  message_type :string(255)
#  image        :binary
#

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
