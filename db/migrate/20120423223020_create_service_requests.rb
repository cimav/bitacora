class CreateServiceRequests < ActiveRecord::Migration
  def change
    create_table :service_requests do |t|
      t.references :user
      t.string     :number, :limit => 20
      t.references :request_type
      t.string     :request_link
      t.text       :description
      t.integer    :status, :default => 1
      t.timestamps
    end
    add_index('service_requests', 'user_id')
    add_index('service_requests', 'request_type_id')
  end
end
