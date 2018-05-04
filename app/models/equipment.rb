class Equipment < ActiveRecord::Base
  attr_accessible :laboratory_id, :name, :description, :hourly_rate, :status, :item_number, :budget_item, :purchase_date, :purchase_price, :internal_hourly_rate, :show_web

  belongs_to :laboratory
  has_many :alerts
  has_many :maintenances
  has_many :requested_service_equipment
  has_many :requested_services, :through => :requested_service_equipment
  
  ACTIVE = 1
  INACTIVE = 2

end
