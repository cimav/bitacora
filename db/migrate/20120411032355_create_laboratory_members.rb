class CreateLaboratoryMembers < ActiveRecord::Migration
  def change
    create_table :laboratory_members do |t|
      t.references :laboratory
      t.references :user
      t.string     :status, :default => 1 
      t.timestamps
    end
    add_index('laboratory_members', 'laboratory_id')
    add_index('laboratory_members', 'user_id')
  end
end
