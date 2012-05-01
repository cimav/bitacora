class Sample < ActiveRecord::Base
  attr_accessible :identification, :description, :status, :consecutive
  belongs_to :service_request
  has_many :requested_service
end
