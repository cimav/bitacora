class CreateCertificationClassifications < ActiveRecord::Migration
  def change
    create_table :certification_classifications do |t|
      t.string     :name
      t.text       :description
      t.timestamps null: false
    end
  end
end
