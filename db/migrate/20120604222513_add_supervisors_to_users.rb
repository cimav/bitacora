class AddSupervisorsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :supervisor1_id, :integer
    add_column :users, :supervisor2_id, :integer
    add_index('users', 'supervisor1_id')
    add_index('users', 'supervisor2_id')
  end
end
