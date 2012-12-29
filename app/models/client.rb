class Client < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :external_request
  belongs_to :client_type
  belongs_to :country
  belongs_to :state
  has_many   :client_contacts
end
