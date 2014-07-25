class ServiceRequestParticipation < ActiveRecord::Base
  belongs_to :service_request
  belongs_to :user
end
