class Laboratory < ActiveRecord::Base
  attr_accessible :name, :business_unit_id
  has_many :laboratory_requests
  has_many :laboratory_services

  ACTIVE = 1
  INACTIVE = 2
end