class CreateRequestedServiceTechnicians < ActiveRecord::Migration
  def change
    create_table :requested_service_technicians do |t|
      t.references :requested_service
      t.references :user
      t.decimal    :hours,       :precision => 4, :scale => 2
      t.decimal    :hourly_wage, :precision => 6, :scale => 2
      t.text       :details
      t.timestamps
    end
    add_index('requested_service_technicians', 'requested_service_id')
    add_index('requested_service_technicians', 'user_id')
  end
end
