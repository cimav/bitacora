class Material < ActiveRecord::Base
  attr_accessible :name, :description, :unit_id, :unit_price, :cas, :formula, :material_type_id, :status
  belongs_to :unit
  belongs_to :material_type
  
  ACTIVE = 1
  INACTIVE = 2
end
