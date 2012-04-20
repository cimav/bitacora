class Laboratory < ActiveRecord::Base
  attr_accessible :name, :business_unit_id
  has_many :laboratory_requests
end
