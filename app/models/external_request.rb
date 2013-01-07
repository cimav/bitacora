class ExternalRequest < ActiveRecord::Base

  attr_accessible :client_id, :client_contact_id, :request_date, :service_number, :is_acredited, :client_agreements, :notes

  belongs_to :service_request
  belongs_to :client
  belongs_to :client_contact

end
