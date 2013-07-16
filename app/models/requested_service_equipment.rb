class RequestedServiceEquipment < ActiveRecord::Base
  attr_accessible :requested_service_id, :equipment_id, :hours, :hourly_rate, :details
  belongs_to :equipment
  belongs_to :requested_service

  validates :requested_service_id, :presence => true
  validates :equipment_id, :presence => true
  validates :hours, :presence => true
end
