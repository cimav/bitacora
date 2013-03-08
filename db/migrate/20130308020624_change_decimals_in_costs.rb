class ChangeDecimalsInCosts < ActiveRecord::Migration
  def up
    change_table :requested_service_materials do |t|
      t.change :quantity, :decimal, :precision => 10, :scale => 4
    end
    change_table :requested_service_others do |t|
      t.change :price, :decimal, :precision => 10, :scale => 2
    end
  end

  def down
    change_table :requested_service_materials do |t|
      t.change :quantity, :decimal, :precision => 6, :scale => 4
    end
    change_table :requested_service_others do |t|
      t.change :price, :decimal, :precision => 6, :scale => 2
    end
  end
end
