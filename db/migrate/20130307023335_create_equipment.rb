class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.references :laboratory
      t.string     :name
      t.text       :description
      t.decimal    :hourly_rate, :precision => 6, :scale => 2
      t.string     :status, :default => 1
      t.timestamps
    end
    add_index('equipment', 'laboratory_id')
  end
end
