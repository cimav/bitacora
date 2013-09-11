class AddConsecutiveToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :consecutive, :integer
  end
end
