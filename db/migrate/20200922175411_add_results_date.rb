class AddResultsDate < ActiveRecord::Migration
  def change
  	add_column :requested_services, :results_date, :date
  end
end
