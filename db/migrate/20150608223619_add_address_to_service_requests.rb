class AddAddressToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_client_address1, :string
    add_column :service_requests, :vinculacion_client_address2, :string
    add_column :service_requests, :vinculacion_client_city,     :string
    add_column :service_requests, :vinculacion_client_state,    :string
    add_column :service_requests, :vinculacion_client_country,  :string
    add_column :service_requests, :vinculacion_client_zip,      :string
  end
end