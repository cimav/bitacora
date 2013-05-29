class ServiceType < ActiveRecord::Base
  attr_accessible :short_name, :name
  has_many :laboratory_services
  validates :name, :presence => true, :uniqueness => true
  validates :short_name, :presence => true, :uniqueness => true
end
