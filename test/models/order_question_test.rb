# == Schema Information
#
# Table name: order_questions
#
#  id         :integer          not null, primary key
#  order_type :string(255)
#  text       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class OrderQuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
