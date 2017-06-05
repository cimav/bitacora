class ProjectQuoteEquipment < ActiveRecord::Base
  attr_accessible :requested_service_id, :equipment_id, :hours, :hourly_rate, :details
  belongs_to :equipment
  belongs_to :project_quote

  validates :project_quote_id, :presence => true
  validates :equipment_id, :presence => true
  validates :hours, :presence => true
end
