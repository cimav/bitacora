class Department < ActiveRecord::Base
  attr_accessible :name, :business_unit_id, :prefix, :description, :user_id
  belongs_to :user
  belongs_to :business_unit
  has_many :users

  ACTIVE = 1
  INACTIVE = 2
end
