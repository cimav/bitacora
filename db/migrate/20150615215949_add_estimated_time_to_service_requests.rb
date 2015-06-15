class AddEstimatedTimeToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :estimated_time, :integer, :default => 0
  end
end
