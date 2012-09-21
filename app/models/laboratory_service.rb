class LaboratoryService < ActiveRecord::Base
  attr_accessible :name, :description, :service_type_id, :laboratory_id
  belongs_to :laboratory
  has_many :requested_service
  has_many :users, :through => :requested_service

  validates :name, :presence => true, :uniqueness => true
  validates :service_type_id, :presence => true
  validates :laboratory_id, :presence => true
end
