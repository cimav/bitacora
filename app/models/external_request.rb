class ExternalRequest < ActiveRecord::Base
  attr_accessible :service_number, :request_date, :is_acredited, :client_agreements, :notes
  has_one :service_request
  has_one :client
  has_one :client_contact
end
