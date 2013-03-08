class ChangeTypeToQuantityInMaterials < ActiveRecord::Migration
  def up
    change_table :requested_service_materials do |t|
      t.change :quantity, :decimal, :precision => 6, :scale => 4
    end
  end

  def down
    change_table :requested_service_materials do |t|
      t.change :quantity, :decimal, :precision => 10, :scale => 10
    end
  end
end
