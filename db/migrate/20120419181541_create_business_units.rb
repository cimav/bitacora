class CreateBusinessUnits < ActiveRecord::Migration
  def change
    create_table :business_units do |t| 
      t.string :prefix, :limit => 5
      t.string :name
      t.timestamps
    end
  end
end
