class Maintenance < ActiveRecord::Base

  attr_accessible :equipment_id, :provider_id, :name, :due_date, :real_date
  belongs_to :equipment
  has_one :provider

end
