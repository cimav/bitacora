class CreateLaboratoryServices < ActiveRecord::Migration
  def change
    create_table :laboratory_services do |t|
      t.references :laboratory
      t.string     :name
      t.text       :description
      t.timestamps
    end
    add_index('laboratory_services', 'laboratory_id')
  end
end
