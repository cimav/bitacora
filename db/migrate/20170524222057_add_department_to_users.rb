class AddDepartmentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :department_id, :integer, :default => 0
  end
end
