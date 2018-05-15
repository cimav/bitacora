class AddDatesToMaintenance < ActiveRecord::Migration
  def change
    add_column :maintenances, :expected_date, :date
    add_column :maintenances, :real_date, :date
  end
end
