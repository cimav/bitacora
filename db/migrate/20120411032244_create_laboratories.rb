class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories do |t|
      t.string     :name
      t.string     :prefix, :limit => 5
      t.text       :description
      t.references :business_unit
      t.references :user
      t.integer    :status, :default => 1
      t.timestamps
    end
    add_index('laboratories', 'user_id')
  end
end
