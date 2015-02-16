class AddVinculacionClientNameToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_client_name, :string
  end
end
