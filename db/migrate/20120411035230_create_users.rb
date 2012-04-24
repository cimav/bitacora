class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :email
      t.string  :employee_number
      t.string  :first_name
      t.string  :last_name
      t.decimal :hourly_wage, :precision => 6, :scale => 2
      t.string  :access, :default => 1 
      t.string  :status, :default => 1 
      t.timestamps
    end
  end
end
