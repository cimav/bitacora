class Laboratory < ActiveRecord::Base
  attr_accessible :name, :business_unit_id
  has_many :laboratory_requests
  has_many :laboratory_services
  has_many :laboratory_members
  has_many :users, :through => :laboratory_members

  ACTIVE = 1
  INACTIVE = 2
end
