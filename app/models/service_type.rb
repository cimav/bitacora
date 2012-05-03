class ServiceType < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :laboratory_services
end
