class AddSupervisorToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :supervisor_id, :integer
    add_index('service_requests', 'supervisor_id')
  end
end
