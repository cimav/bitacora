class RequestedServiceMaterial < ActiveRecord::Base
  attr_accessible :requested_service_id, :material_id, :quantity, :unit_price, :details
  belongs_to :material
  belongs_to :requested_service
end
