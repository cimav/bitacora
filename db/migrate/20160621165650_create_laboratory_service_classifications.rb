class CreateLaboratoryServiceClassifications < ActiveRecord::Migration
  def change
    create_table :laboratory_service_classifications do |t|
      t.references :laboratory
      t.string     :name
      t.text       :description
      t.integer    :status
      t.timestamps null: false
    end
  end
end