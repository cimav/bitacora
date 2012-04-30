class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id
end
