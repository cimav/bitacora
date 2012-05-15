class CreateServiceFiles < ActiveRecord::Migration
  def change
    create_table :service_files do |t|
      t.references :user
      t.references :service_request
      t.references :sample
      t.references :requested_service
      t.integer    :file_type
      t.string     :description
      t.string     :file
      t.timestamps
    end
    add_index('service_files', 'user_id')
    add_index('service_files', 'service_request_id')
    add_index('service_files', 'sample_id')
    add_index('service_files', 'requested_service_id')
  end
end
