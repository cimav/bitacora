class LaboratoryRequest < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :laboratory
end
