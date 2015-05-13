class AddVinculacionClientDataToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_client_contact, :string
    add_column :service_requests, :vinculacion_client_email,   :string
    add_column :service_requests, :vinculacion_client_phone,   :string
    
  end
end
