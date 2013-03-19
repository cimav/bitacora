class Laboratory < ActiveRecord::Base
  attr_accessible :name, :business_unit_id, :prefix, :description, :user_id
  has_many :laboratory_requests
  has_many :laboratory_services
  has_many :laboratory_members
  has_many :equipment
  has_many :users, :through => :laboratory_members
  has_many :requested_services, :through => :laboratory_services

  ACTIVE = 1
  INACTIVE = 2
end
