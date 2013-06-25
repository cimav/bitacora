class AddCasFormulaTypeToMaterials < ActiveRecord::Migration
  def change
  	add_column :materials, :cas, :string
  	add_column :materials, :formula, :string
  	add_column :materials, :material_type_id, :integer
  end
end
