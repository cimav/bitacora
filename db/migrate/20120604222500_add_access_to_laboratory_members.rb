class AddAccessToLaboratoryMembers < ActiveRecord::Migration
  def change
    add_column :laboratory_members, :access, :string, :default => 1 
  end
end
