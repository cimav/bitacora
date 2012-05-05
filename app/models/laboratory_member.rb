class LaboratoryMember < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :laboratory
  belongs_to :user
end
