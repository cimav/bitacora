class AddEvaluationCostToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :evaluation_cost, :decimal, :precision => 10, :scale => 2
  end
end
