class AddFileToMaintenances < ActiveRecord::Migration
  def change  	
    add_column :maintenances, :file, :string
  end
end
