# == Schema Information
#
# Table name: steps
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  order_type :string(255)
#

class Step < ActiveRecord::Base
end
