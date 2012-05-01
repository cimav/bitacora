class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.references :service_request
      t.integer    :consecutive
      t.string     :identification
      t.text       :description
      t.string     :status, :default => 1 
      t.timestamps
    end
    add_index('samples', 'service_request_id')
  end
end
