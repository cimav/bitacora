class RequestedServiceOther < ActiveRecord::Base
  attr_accessible :title, :body
  attr_accessible :requested_service_id, :other_type, :concept, :price
  belongs_to :other_type
  belongs_to :requested_service

  validates :requested_service_id, :presence => true
  validates :other_type, :presence => true
  validates :concept, :presence => true
  validates :price, :presence => true
end
