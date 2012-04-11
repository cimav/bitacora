class CreateRequestedServiceEquipments < ActiveRecord::Migration
  def change
    create_table :requested_service_equipments do |t|
      t.references :requested_service
      t.references :equipment
      t.decimal    :hours,       :precision => 4, :scale => 2
      t.decimal    :hourly_rate, :precision => 6, :scale => 2
      t.text       :details
      t.timestamps
    end
    add_index('requested_service_equipments', 'requested_service_id')
    add_index('requested_service_equipments', 'equipment_id')
  end
end
