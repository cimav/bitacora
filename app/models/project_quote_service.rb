class ProjectQuoteService < ActiveRecord::Base
	belongs_to :project_quote
	has_one    :laboratory_service
end
