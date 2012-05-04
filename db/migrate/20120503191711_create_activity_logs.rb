class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.references :user
      t.references :service_request
      t.references :sample
      t.references :requested_service
      t.text       :message
      t.timestamps
    end
    add_index('activity_logs', 'user_id')
    add_index('activity_logs', 'service_request_id')
    add_index('activity_logs', 'sample_id')
    add_index('activity_logs', 'requested_service_id')
  end
end
