class CreateProjectQuoteEquipments < ActiveRecord::Migration
  def change
    create_table :project_quote_equipments do |t|
      t.references :project_quote
      t.references :equipment
      t.decimal    :hours,       :precision => 4, :scale => 2
      t.decimal    :hourly_rate, :precision => 6, :scale => 2
      t.text       :details
      t.timestamps null: false
    end
  end
end
