class Client < ActiveRecord::Base
  attr_accessible :name, :client_type_id, :rfc, :address1, :address2, :city, :state_id, :country_id, :phone, :fax, :email
  has_many   :external_request
  belongs_to :client_type
  belongs_to :country
  belongs_to :state
  has_many   :client_contacts

  validates :name, :presence => true, :uniqueness => true

  ACTIVE = 1
  INACTIVE = 2

end
