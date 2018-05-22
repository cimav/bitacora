class AddMaintenanceToActivity < ActiveRecord::Migration
  def change
  	add_column :activity_logs, :maintenance_id, :integer, :default => 0
  end
end
