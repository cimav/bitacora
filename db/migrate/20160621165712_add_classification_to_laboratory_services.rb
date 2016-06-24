class AddClassificationToLaboratoryServices < ActiveRecord::Migration
  def change
  	add_column :laboratory_services, :laboratory_service_classification_id, :integer, :default => 0
  end
end
