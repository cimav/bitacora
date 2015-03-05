class AddIsCatalogToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :is_catalog, :integer, :default => 0
  end
end
