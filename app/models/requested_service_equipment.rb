class RequestedServiceEquipment < ActiveRecord::Base
  attr_accessible :requested_service_id, :equipment_id, :hours, :hourly_rate, :details
  belongs_to :equipment
  belongs_to :requested_service
end
