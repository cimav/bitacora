class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string     :name
      t.string     :phone
      t.string     :email
      t.text       :address
      t.integer    :status, :default => 1
      t.timestamps null: false
    end
  end
end
