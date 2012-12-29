class AddClientAndContactToExternalRequests < ActiveRecord::Migration
  def change
    add_column :external_requests, :client_id, :integer
    add_index('external_requests', 'client_id')
    add_column :external_requests, :client_contact_id, :integer
    add_index('external_requests', 'client_contact_id')
  end
end
