class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :access, :default => 1 
      t.string :status, :default => 1 
      t.timestamps
    end
  end
end
