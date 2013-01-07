class ClientContact < ActiveRecord::Base
  attr_accessible :client_id, :name, :phone, :email
  belongs_to :client
  belongs_to :external_request

  validates :name, :presence => true, :uniqueness => true

end
