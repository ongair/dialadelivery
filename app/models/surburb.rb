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

  def get_coordinates
  	coordinates = Geocoder.coordinates(self.name)
  end
end
