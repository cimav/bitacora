class AddVinculacionDatesToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :vinculacion_delivery, :string
    add_column :service_requests, :vinculacion_start_date, :date
    add_column :service_requests, :vinculacion_end_date, :date
    add_column :service_requests, :vinculacion_days, :integer
  end
end
