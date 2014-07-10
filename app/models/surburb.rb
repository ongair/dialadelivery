# == Schema Information
#
# Table name: surburbs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  outlet_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Surburb < ActiveRecord::Base
  belongs_to :outlet
end
