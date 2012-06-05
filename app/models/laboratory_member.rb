class LaboratoryMember < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :laboratory
  belongs_to :user

  ACCESS_MEMBER   = 1
  ACCESS_TRAINED  = 2
  ACCESS_ADMIN    = 99
end
