class CreateProjectQuoteOthers < ActiveRecord::Migration
  def change
    create_table :project_quote_others do |t|
      t.references :project_quote
      t.integer    :other_type
      t.string     :concept
      t.text       :details
      t.decimal    :quantity,  :precision => 4, :scale => 2
      t.decimal    :price,     :precision => 6, :scale => 2
      t.timestamps null: false
    end
  end
end
