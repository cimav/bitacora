class CreateRequestedServices < ActiveRecord::Migration
  def change
    create_table :requested_services do |t|
      t.references :laboratory_service 
      t.references :sample
      t.text       :details
      t.string :status, :default => 1 
      t.timestamps
    end
    add_index('requested_services', 'sample_id')
    add_index('requested_services', 'laboratory_service_id')
  end
end