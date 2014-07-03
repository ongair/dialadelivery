# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  text        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  customer_id :integer
#

class Message < ActiveRecord::Base
  belongs_to :customer
end
