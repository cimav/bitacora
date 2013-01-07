class ExternalRequest < ActiveRecord::Base

  attr_accessible :client_id, :client_contact_id, :request_date, :service_number, :is_acredited, :client_agreements, :notes

  belongs_to :service_request
  has_one :client
  has_one :client_contact

end
