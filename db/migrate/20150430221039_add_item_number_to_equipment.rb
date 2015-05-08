class AddItemNumberToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :item_number, :string
  end
end
