class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.references :laboratory_request
      t.string     :identification
      t.text       :description
      t.string     :status, :default => 1 
      t.timestamps
    end
    add_index('samples', 'laboratory_request_id')
  end
end
