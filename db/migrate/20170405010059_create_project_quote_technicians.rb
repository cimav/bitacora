class CreateProjectQuoteTechnicians < ActiveRecord::Migration
  def change
    create_table :project_quote_technicians do |t|
      t.references :project_quote
      t.references :user
      t.decimal    :hours,       :precision => 4, :scale => 2
      t.decimal    :hourly_wage, :precision => 6, :scale => 2
      t.text       :details
      t.timestamps null: false
    end
  end
end
