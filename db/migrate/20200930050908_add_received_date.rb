class AddReceivedDate < ActiveRecord::Migration
  def change
    add_column :requested_services, :received_date, :datetime
  end
end
