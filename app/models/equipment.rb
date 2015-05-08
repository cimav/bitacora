class Equipment < ActiveRecord::Base
  attr_accessible :laboratory_id, :name, :description, :hourly_rate, :status, :item_number

  belongs_to :laboratory
  
  ACTIVE = 1
  INACTIVE = 2
end
