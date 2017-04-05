class ProjectQuoteTechnician < ActiveRecord::Base
  attr_accessible :project_quote_id, :user_id, :hours, :hourly_wage, :details
  belongs_to :user
  belongs_to :project_quote
  validates :user_id, :presence => true
  validates :hours, :presence => true
end
