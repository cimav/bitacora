class LaboratoryServiceClassification < ActiveRecord::Base
  attr_accessible :name, :description, :laboratory_id, :status
  belongs_to :laboratory

  ACTIVE = 1
  INACTIVE = 2
end
