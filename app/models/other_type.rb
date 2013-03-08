class OtherType < ActiveRecord::Base
  attr_accessible :name, :description
  has_many :requested_service_others
end
