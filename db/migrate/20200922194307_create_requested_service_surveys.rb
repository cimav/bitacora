class CreateRequestedServiceSurveys < ActiveRecord::Migration
  def change
    create_table :requested_service_surveys do |t|
      t.references :requested_service
      t.integer :q1
      t.integer :q2
      t.integer :q3
      t.integer :q4
      t.integer :q5
      t.text    :notes
      t.string  :token
      t.timestamps null: false
    end
  end
end
