class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :short_name, :limit => 10
      t.string :name
      t.timestamps
    end
  end
end
