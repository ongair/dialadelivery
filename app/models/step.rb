# == Schema Information
#
# Table name: steps
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Step < ActiveRecord::Base
end
