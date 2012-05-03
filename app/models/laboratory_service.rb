class LaboratoryService < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :laboratory
  has_many :requested_service
end
