class Material < ActiveRecord::Base
  attr_accessible :name, :description, :unit_id, :unit_price, :status
  belongs_to :unit
  
  ACTIVE = 1
  INACTIVE = 2
end
