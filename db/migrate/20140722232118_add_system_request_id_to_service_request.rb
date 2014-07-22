class AddSystemRequestIdToServiceRequest < ActiveRecord::Migration
  def change
    add_column :service_requests, :system_request_id, :integer
  end
end
