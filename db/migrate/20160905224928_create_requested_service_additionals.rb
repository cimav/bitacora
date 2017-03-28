class CreateRequestedServiceAdditionals < ActiveRecord::Migration
  def change
    create_table :requested_service_additionals do |t|
      t.references :requested_service_id
      t.references :laboratory_service_additional
      t.string     :name
      t.text       :value
      t.timestamps null: false
    end
  end
end
