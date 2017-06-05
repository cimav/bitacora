class CreateLaboratoryServiceAdditionals < ActiveRecord::Migration
  def change
    create_table :laboratory_service_additionals do |t|
      t.references :laboratory_service
      t.string     :name
      t.integer    :type
      t.text       :value
      t.timestamps null: false
    end
  end
end
