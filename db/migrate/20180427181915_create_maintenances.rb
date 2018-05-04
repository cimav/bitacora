class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      t.references :equipment
      t.references :provider
      t.string     :name
      t.string     :purchase_request
      t.text       :description
      t.string     :status, :default => 1 
      t.timestamps null: false
    end
  end
end
