class RequestedServiceTechnician < ActiveRecord::Base
  attr_accessible :requested_service_id, :user_id, :hours, :hourly_wage, :details, :participation
  belongs_to :user
  belongs_to :requested_service
end
