class AddExclusiveToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :is_exclusive_vinculacion, :integer, :default => 0
  end
end
