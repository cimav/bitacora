class CreateProjectQuoteServices < ActiveRecord::Migration
  def change
    create_table :project_quote_services do |t|
      t.references :project_quote
      t.references :requested_service
      t.integer    :quantity
      t.timestamps null: false
    end
  end
end
