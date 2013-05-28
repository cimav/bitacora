class AddFromIdToRequestedServices < ActiveRecord::Migration
  def change
    add_column :requested_services, :from_id, :integer
  end
end
