class RequestedServiceMaterial < ActiveRecord::Base
  attr_accessible :requested_service_id, :material_id, :quantity, :unit_price, :details
  belongs_to :material
  belongs_to :requested_service

  validates :requested_service_id, :presence => true
  validates :material_id, :presence => true
  validates :quantity, :presence => true
end
