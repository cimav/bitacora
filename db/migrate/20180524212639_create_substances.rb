class CreateSubstances < ActiveRecord::Migration
  def change
    create_table :substances do |t|
      t.references :laboratory
      t.string     :name
      t.string     :quantity
      t.text       :description
      t.string     :container
      t.date       :expire_date
      t.integer    :status, :default => 1
      t.references :user
      t.timestamps null: false
    end
  end
end
