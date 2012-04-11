class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string     :name
      t.text       :description
      t.references :unit
      t.decimal    :unit_price, :precision => 6, :scale => 2
      t.string     :status, :default => 1 
      t.timestamps
    end
  end
end
