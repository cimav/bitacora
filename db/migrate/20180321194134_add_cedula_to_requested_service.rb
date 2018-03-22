class AddCedulaToRequestedService < ActiveRecord::Migration
  def change
  	add_column :requested_services, :cedula_id, :integer, :default => 0
  end
end
