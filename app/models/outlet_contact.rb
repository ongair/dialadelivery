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

class OutletContact < ActiveRecord::Base
  belongs_to :outlet
end
