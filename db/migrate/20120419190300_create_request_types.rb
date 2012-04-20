class CreateRequestTypes < ActiveRecord::Migration
  def change
    create_table :request_types do |t|
      t.string :short_name, :limit => 20
      t.string :name
      t.timestamps
    end
  end
end
