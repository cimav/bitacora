class FixProjectQuoteLabServiceColumn < ActiveRecord::Migration
  def change
  	rename_column :project_quote_services, :requested_service_id, :laboratory_service_id
  end
end
