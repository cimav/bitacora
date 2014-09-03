class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.references :service_request
      t.references :user
      t.integer    :collaboration_type
      t.integer    :status, :default => 1 
      t.timestamps
    end
    add_index('collaborators', 'service_request_id')
    add_index('collaborators', 'user_id')
  end
end
