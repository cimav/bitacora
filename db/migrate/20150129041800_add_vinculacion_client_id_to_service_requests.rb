class AddVinculacionClientIdToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_client_id, :integer
  end
end
