class Certification < ActiveRecord::Base
  belongs_to :laboratory_service
  belongs_to :certification_type
  belongs_to :certification_type_classification
end
