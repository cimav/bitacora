class CreateLaboratoryServices < ActiveRecord::Migration
  def change
    create_table :laboratory_services do |t|
      t.references :laboratory
      t.references :service_type
      t.string     :name
      t.text       :description
      t.timestamps
    end
    add_index('laboratory_services', 'laboratory_id')
    add_index('laboratory_services', 'service_type_id')
  end
end
