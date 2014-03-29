class AddSystemStatusToServiceRequest < ActiveRecord::Migration
  def change
    add_column :service_requests, :system_status, :integer, :default => 1
  end
end
