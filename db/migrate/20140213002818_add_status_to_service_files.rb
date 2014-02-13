class AddStatusToServiceFiles < ActiveRecord::Migration
  def change
    add_column :service_files, :status, :integer, :default => 1
  end
end
