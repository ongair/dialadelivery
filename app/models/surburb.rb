# == Schema Information
#
# Table name: surburbs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  outlet_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  approved   :boolean
#

class Surburb < ActiveRecord::Base
	belongs_to :outlet

	def self.get_surburb text
		Surburb.where(Surburb.arel_table[:name].matches(text)).take
	end
end
