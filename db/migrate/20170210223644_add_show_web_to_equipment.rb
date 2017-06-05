class AddShowWebToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :show_web, :boolean, :default => 0
  end
end
