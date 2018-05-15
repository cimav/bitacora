class ActivityLog < ActiveRecord::Base
  attr_accessible :message_type, :message, :user_id, :service_request_id, :sample_id, :requested_service_id, :requested_service_status, :maintenance_id

  belongs_to :user
  belongs_to :service_request
  belongs_to :sample
  belongs_to :requested_service
  belongs_to :maintenance
end
