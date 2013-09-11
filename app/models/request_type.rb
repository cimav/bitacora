class RequestType < ActiveRecord::Base
  attr_accessible :short_name, :name, :prefix
  has_many :service_request
end
