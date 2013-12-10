class AddInternalCostToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :internal_cost, :decimal, :precision => 10, :scale => 2
  end
end
