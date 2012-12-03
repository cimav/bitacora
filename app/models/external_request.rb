class ExternalRequest < ActiveRecord::Base
  # attr_accessible :title, :body
  has_one :service_request
end
