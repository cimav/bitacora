class AddStatusToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :status, :integer, :default => 0
  end
end
