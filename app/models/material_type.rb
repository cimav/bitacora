class MaterialType < ActiveRecord::Base
  attr_accessible :name, :description
  has_many :materials
end
