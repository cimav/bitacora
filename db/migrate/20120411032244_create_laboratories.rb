class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories do |t|
      t.string     :name
      t.text       :description
      t.references :user
      t.timestamps
    end
    add_index('laboratories', 'user_id')
  end
end
