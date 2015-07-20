class CreateSampleDetails < ActiveRecord::Migration
  def change
    create_table :sample_details do |t|
      t.references :sample
      t.integer    :consecutive
      t.string     :client_identification
      t.text       :notes
      t.string     :status, :default => 1

      t.timestamps null: false
    end
  end
end
