class CreateCertifications < ActiveRecord::Migration
  def change
    create_table :certifications do |t|
      t.references :laboratory_service
      t.references :certification_type
      t.references :certification_classification
      t.string     :reference
      t.string     :identification
      t.text       :description
      t.date       :expire_date
      t.references :user
      t.integer    :status, :default => 1
      t.timestamps null: false
    end
  end
end
