class CreateRequestedServiceMaterials < ActiveRecord::Migration
  def change
    create_table :requested_service_materials do |t|
      t.references :requested_service
      t.references :material
      t.decimal    :quantity, :precision => 10, :scale => 10
      t.decimal    :unit_price, :precision => 6, :scale => 2
      t.text       :details
      t.timestamps
    end
    add_index('requested_service_materials', 'requested_service_id')
    add_index('requested_service_materials', 'material_id')
  end
end
