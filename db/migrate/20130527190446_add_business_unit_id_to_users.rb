class AddBusinessUnitIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :business_unit_id, :integer, :default => 1
  end
end
