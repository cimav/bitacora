class CreateLaboratoryImages < ActiveRecord::Migration
  def change
    create_table :laboratory_images do |t|
      t.references :user
      t.references :laboratory
      t.string     :description
      t.string     :file
      t.timestamps null: false
    end
    add_index('laboratory_images', 'laboratory_id')
  end
end