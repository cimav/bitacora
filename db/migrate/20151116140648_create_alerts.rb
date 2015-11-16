class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.references :user
      t.references :laboratory_service
      t.integer    :technician
      t.references :equipment
      t.datetime   :start_date
      t.datetime   :end_date
      t.string     :message_type
      t.text       :message
      t.integer    :status
      t.timestamps
    end
    add_index('alerts', 'user_id')
    add_index('alerts', 'laboratory_service_id')
    add_index('alerts', 'technician')
    add_index('alerts', 'equipment_id')
  end
end
