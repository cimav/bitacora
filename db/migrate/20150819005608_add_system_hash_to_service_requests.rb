class AddSystemHashToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_hash, :string
  end
end
