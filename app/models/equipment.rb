class Equipment < ActiveRecord::Base
  attr_accessible :laboratory_id, :name, :description, :hourly_rate, :status

  belongs_to :laboratory
  
  ACTIVE = 1
  INACTIVE = 2
end
