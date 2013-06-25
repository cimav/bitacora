class CreateMaterialTypes < ActiveRecord::Migration
  def change
    create_table :material_types do |t|
      t.string     :name
      t.text       :description
      t.string     :status, :default => 1
      t.timestamps
    end
  end
end
