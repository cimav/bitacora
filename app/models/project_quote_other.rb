class ProjectQuoteOther < ActiveRecord::Base
  attr_accessible :project_quote_id, :other_type_id, :price, :concept
  belongs_to :other_type
  belongs_to :project_quote

  validates :project_quote_id, :presence => true
  validates :other_type, :presence => true
  validates :price, :presence => true
end
