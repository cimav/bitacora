class AddSystemIdToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :system_id, :string
  end
end
