class AddFinishedDate < ActiveRecord::Migration
  def change
  	add_column :requested_services, :finished_date, :datetime
  end
end
