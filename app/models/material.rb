class Material < ActiveRecord::Base
  attr_accessible :name, :description, :unit_id, :unit_price, :status
  belongs_to :unit
end
