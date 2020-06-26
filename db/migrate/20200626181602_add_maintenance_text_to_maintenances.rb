class AddMaintenanceTextToMaintenances < ActiveRecord::Migration
  def change
  	add_column :maintenances, :provider_text, :string
  end
end
