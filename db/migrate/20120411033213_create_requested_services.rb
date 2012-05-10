class CreateRequestedServices < ActiveRecord::Migration
  def change
    create_table :requested_services do |t|
      t.references :laboratory_service 
      t.references :sample
      t.integer    :consecutive
      t.string     :number, :limit => 20
      t.text       :details
      t.references :user
      t.integer    :suggested_user_id
      t.string :status, :default => 1 
      t.timestamps
    end
    add_index('requested_services', 'sample_id')
    add_index('requested_services', 'laboratory_service_id')
    add_index('requested_services', 'user_id')
    add_index('requested_services', 'suggested_user_id')
  end
end
