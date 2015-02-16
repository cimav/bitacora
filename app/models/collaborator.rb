class Collaborator < ActiveRecord::Base
  attr_accessible :user_id, :status, :collaboration_type, :service_request_id
  belongs_to :service_request
  belongs_to :user
end
