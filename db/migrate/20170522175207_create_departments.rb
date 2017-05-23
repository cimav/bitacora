class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string     :name
      t.string     :prefix, :limit => 5
      t.text       :description
      t.references :business_unit
      t.references :user
      t.integer    :status, :default => 1
      t.timestamps null: false
    end
  end
end
