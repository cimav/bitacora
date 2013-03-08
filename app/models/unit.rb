class Unit < ActiveRecord::Base
  attr_accessible :short_name, :short_name
  has_many :materials
end
